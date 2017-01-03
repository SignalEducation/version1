# coding: utf-8
require 'mailchimp'
require 'prawn'
require 'mandrill'

class ApplicationController < ActionController::Base

  # This array must be in ascending score order.
  DIFFICULTY_LEVELS = [
      {name: 'easy', score: 3, run_time_multiplier: 1},
      {name: 'medium', score: 5, run_time_multiplier: 1.5},
      {name: 'difficult', score: 10, run_time_multiplier: 2.5}
  ]

  DIFFICULTY_LEVEL_NAMES = DIFFICULTY_LEVELS.map { |x| x[:name] }

  def self.find_multiplier_for_difficulty_level(the_name)
    DIFFICULTY_LEVEL_NAMES.include?(the_name) ?
        DIFFICULTY_LEVELS.find { |x| x[:name] == the_name }[:run_time_multiplier] : 0
  end

  before_action :authenticate_if_staging
  before_action :check_current_corporate_logged_in, if: 'current_corporate'
  before_action :setup_mcapi

  def authenticate_if_staging
    if Rails.env.staging? && params[:first_element] != 'api'
      authenticate_or_request_with_http_basic 'Staging' do |name, password|
        name == 'signal' && password == '27(South!)'
      end
    end
  end

  def check_current_corporate_logged_in
    unless controller_name == 'user_sessions' || controller_name == 'corporate_profiles' || controller_name == 'routes' || controller_name == 'user_password_resets' || controller_name == 'footer_pages' || controller_name == 'user_verifications'
      logged_in_required
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale        # not for Api::
  before_action :set_session_stuff # not for Api::
  before_action :process_referral_code # not for Api::
  before_action :set_assets_from_subdomain
  before_action :set_navbar_and_footer

  helper_method :current_user_session, :current_user, :current_corporate

  Time::DATE_FORMATS[:simple] = I18n.t('controllers.application.datetime_formats.simple')
  Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.datetime_formats.standard')
  Date::DATE_FORMATS[:simple] = I18n.t('controllers.application.date_formats.simple')
  Date::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')

  ### User access control and authentication

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  #def current_user
  #  if @current_user && @current_user.corporate_customer? && @current_user.session_key != session[:session_id]
  #    flash[:notice] = I18n.t('controllers.application.simultaneous_logins_detected')
  #    current_user_session.destroy
  #    return nil
  #  else
  #    return @current_user if defined?(@current_user)
  #    @current_user = current_user_session && current_user_session.record
  #  end
  #end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def current_corporate
    if current_user
      CorporateCustomer.find_by_subdomain(request.subdomain) if current_user.corporate_customer? || current_user.corporate_student?
    else
      CorporateCustomer.find_by_subdomain(request.subdomain)
    end
  end

  def set_navbar_and_footer
    @navbar = 'standard'
    @footer = 'standard'
  end

  def set_assets_from_subdomain
    corporate_domains = CorporateCustomer.all.map(&:subdomain)
    if request.subdomain.present? && corporate_domains.include?(request.subdomain)
      asset_folder = "#{Rails.root}/app/assets/stylesheets/#{request.subdomain}/application.scss"
      if File.exists?(asset_folder)
        @css_root = "#{request.subdomain}/application"
      else
        @css_root = 'application'
      end
    else
      @css_root = 'application'
    end
  end

  def logged_in_required
    unless current_user
      session[:return_to] = request.original_url
      flash[:error] = I18n.t('controllers.application.logged_in_required.flash_error')
      redirect_to sign_in_url
      false
    end
  end

  def logged_out_required
    if current_user
      flash[:error] = I18n.t('controllers.application.logged_out_required.flash_error')
      redirect_to root_url
      false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    if session[:return_to]
      destination = session[:return_to]
      session[:return_to] = nil
    else
      destination = default
      session[:return_to] = nil
    end
    redirect_to(destination)
  end

  def ensure_user_is_of_type(authorised_features)
    logged_in_required
    the_user_group = current_user.user_group
    # for a list of permitted features, see UserGroup::FEATURES
    permission_granted = false
    authorised_features.each do |permitted_thing|
      if (the_user_group.individual_student && permitted_thing == 'individual_student') ||
         (the_user_group.corporate_student  && permitted_thing == 'corporate_student') ||
         (the_user_group.tutor              && permitted_thing == 'tutor') ||
         (the_user_group.blogger            && permitted_thing == 'blogger') ||
         (the_user_group.corporate_customer && permitted_thing == 'corporate_customer') ||
         (the_user_group.content_manager    && permitted_thing == 'content_manager') ||
         (the_user_group.complimentary    && permitted_thing == 'complimentary') ||
         (the_user_group.site_admin)
        permission_granted = true
      end
    end
    unless permission_granted
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
      false
    end
  end
  helper_method :ensure_user_is_of_type

  def paywall_checkpoint
    allowed     = {course_content: {view_all: true, reason: nil}}

    if current_user && current_user.permission_to_see_content(@course)
      result = allowed
    else
      result = not_allowed
    end
    result
  end
  helper_method :paywall_checkpoint

  #### Locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    Rails.logger.debug "DEBUG: ApplicationController#default_url_options: Received options: #{options.inspect}\n"
    { locale: I18n.locale }
  end


  #### Session GUIDs and user tracking

  def current_session_guid
    cookies.permanent.encrypted[:session_guid]
  end
  helper_method :current_session_guid


  def set_session_stuff
    cookies.permanent.encrypted[:session_guid] ||= {value: ApplicationController.generate_random_code(64), httponly: true}
    cookies.encrypted[:first_session_landing_url] ||= {value: request.filtered_path, httponly: true}
    cookies.encrypted[:latest_session_landing_url] ||= {value: request.filtered_path, httponly: true}
    cookies.encrypted[:post_sign_up_redirect_path] ||= {value: nil, httponly: true}
  end

  def reset_latest_session_landing_url
    cookies.encrypted[:latest_session_landing_url] = {value: request.filtered_path, httponly: true}
  end

  def reset_post_sign_up_redirect_path(new_path)
    cookies.encrypted[:post_sign_up_redirect_path] = {value: new_path, httponly: true} if new_path
  end

  def process_referral_code
    # TODO We should probably check also whether request.path matches valid paths (library for students and author page for tutors)
    referral_code = ReferralCode.find_by_code(request.params[:ref_code]) if params[:ref_code]
    if referral_code
      referral_data = request.referrer ? "#{referral_code.code};#{request.referrer}" : referral_code.code

      # Browsers do not send back cookie attributes so we cannot update only value
      # without altering expiration date. Therefore if we detect difference between
      # current referral data and data stored in the cookie we will always save new
      # data and set expiration to next 30 days.
      if referral_code && referral_data != cookies.encrypted[:referral_data]
        cookies.encrypted[:referral_data] = { value: referral_data, expires: 30.days.from_now, httponly: true }
      end
    end
  end

  def process_crush_offers_session_id
    cookies.encrypted[:crush_offers] = { value: params[:co_id], expires: 30.days.from_now, httponly: true } if params[:co_id]
  end


  #### General purpose code

  def self.generate_random_code(number_of_characters=20)
    possible_characters = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    the_answer = ''
    possible_character_size = possible_characters.size
    number_of_characters.times do
      the_answer << possible_characters[rand(possible_character_size)]
    end
    the_answer
  end

  def self.generate_random_number(number_of_characters=5)
    possible_characters = ('0'..'9').to_a
    the_answer = ''
    possible_character_size = possible_characters.size
    number_of_characters.times do
      the_answer << possible_characters[rand(possible_character_size)]
    end
    the_answer
  end

  # tutor/admin-facing
  def course_module_special_link(the_thing)
    # used for tutor-facing links

    if the_thing.class == CourseModuleElement && !the_thing.id.nil?
        edit_course_module_element_url(the_thing.id)

    elsif the_thing.class == CourseModule
      subject_course_url(
                the_thing.subject_course)

    elsif the_thing.class == SubjectCourse
      new_course_modules_for_subject_course_and_name_url(the_thing.name_url)

    else # default route
      subject_course_url
    end
  end
  helper_method :course_module_special_link



  # Library Navigation Links
  def library_special_link(the_thing)
    product_category = SubjectCourseCategory.default_product_category
    subscription_category = SubjectCourseCategory.default_subscription_category
    corporate_category = SubjectCourseCategory.default_corporate_category

    if the_thing.class == Group
      the_thing = the_thing
      subscription_group_url(
                  the_thing.name_url
      )
    elsif the_thing.class == SubjectCourse
      the_thing = the_thing

      if subscription_category && the_thing.subject_course_category_id == subscription_category.id
        #Sub Course
        subscription_course_url(
            the_thing.name_url
        )

      elsif product_category && the_thing.subject_course_category_id == product_category.id
        #Product Course

        if current_user
          diploma_course_url(
              the_thing.name_url
          )
        elsif the_thing.home_page
          product_course_url(
              the_thing.home_page.public_url
          )
        else
          all_diplomas_url
        end

      elsif corporate_category && the_thing.subject_course_category_id == corporate_category.id
        #Corp Course
        subscription_course_url(
            the_thing.name_url
        )

      else
        root_url
      end
    else
      root_url
    end
  end
  helper_method :library_special_link


  def course_special_link(the_thing, direction='forwards')
    if the_thing.class == CourseModule
      library_special_link(
              the_thing.subject_course
      )
    elsif the_thing.class == CourseModuleElement || the_thing.class == CourseModuleJumboQuiz
      course_url(
              the_thing.course_module.subject_course.name_url,
              the_thing.course_module.name_url,
              the_thing.name_url
      )
    else
      library_special_link(the_thing)
    end
  end
  helper_method :course_special_link

  def dashboard_special_link(user = nil)
    user = user || current_user
    redirect_to root_url unless user
    case user.user_group_id
      when UserGroup.default_student_user_group.id
        student_dashboard_url
      when UserGroup.default_complimentary_user_group.id
        student_dashboard_url
      when UserGroup.default_admin_user_group.id
        admin_dashboard_url
      when UserGroup.default_tutor_user_group.id
        tutor_dashboard_url
      when UserGroup.default_corporate_student_user_group.id
        corporate_student_dashboard_url
      when UserGroup.default_corporate_customer_user_group.id
        corporate_customer_dashboard_url
      when UserGroup.default_content_manager_user_group.id
        content_manager_dashboard_url
    else
      student_dashboard_url
    end
  end
  helper_method :dashboard_special_link

  def new_product_order_link(course_url)
    course = SubjectCourse.find_by_name_url(course_url)
    if current_user
      if current_user.valid_subject_course_ids.include?(course.id)
         library_special_link(course)
       else
         users_new_order_url(course_url)
       end
    else
      new_product_user_url(course_url)
    end
  end
  helper_method :new_product_order_link

  def subscription_special_link(user_id)
    user = User.find(user_id)
    if user.individual_student?
      if user.subscriptions.any?
        if user.subscriptions.last.current_status == 'canceled'
          reactivate_account_url
        end

      else
        user_new_subscription_url(user_id)
      end
    else
      root_url
    end
  end
  helper_method :subscription_special_link

  def seo_title_maker(last_element, seo_description, seo_no_index)
    @seo_title = last_element ?
            "#{last_element.to_s.truncate(65)}" :
            'Business Training Library | LearnSignal'
    @seo_description = seo_description.to_s.truncate(156)
    @seo_no_index = seo_no_index
  end

  def tag_manager_data_layer(course)
    @tag_manager_course = course
  end
  helper_method :tag_manager_data_layer

  def setup_mcapi
    @mc = Mailchimp::API.new(ENV['learnsignal_mailchimp_api_key'])
  end

end
