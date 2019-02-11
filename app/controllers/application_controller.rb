# coding: utf-8
require 'mailchimp'
require 'prawn'
require 'mandrill'
require 'csv'

class ApplicationController < ActionController::Base

  before_action :authenticate_if_staging
  before_action :setup_mcapi

  def authenticate_if_staging
    if Rails.env.staging? && !%w(stripe_v02 paypal_webhooks).include?(controller_name)
      authenticate_or_request_with_http_basic 'Staging' do |name, password|
        name == 'signal' && password == '27(South!)'
      end
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale        # not for Api::
  before_action :set_session_stuff # not for Api::
  before_action :set_layout_variables

  helper_method :current_user_session, :current_user

  Time::DATE_FORMATS[:simple] = I18n.t('controllers.application.datetime_formats.simple')
  Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.datetime_formats.standard')
  Date::DATE_FORMATS[:simple] = I18n.t('controllers.application.date_formats.simple')
  Date::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')

  EXCLUDED_CONTROLLERS = %w(orders subscriptions)

  ### User access control and authentication

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def set_current_visit
    if current_visit && !current_visit.user
      current_visit.user = current_user
      current_visit.save!
    end
  end

  def set_layout_variables
    @layout = 'standard'
    @navbar = 'standard'
    @top_margin = true
    @footer = 'standard'
    @groups = Group.all_active.all_in_order
    @footer_content_pages = ContentPage.for_footer
    @footer_landing_pages = HomePage.for_footer

    if ExternalBanner::BANNER_CONTROLLERS.include?(controller_name)
      @banner = ExternalBanner.all_without_parent.render_for(controller_name).all_in_order.first
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

  def ensure_user_has_access_rights(authorised_features)
    logged_in_required
    the_user_group = current_user.user_group
    permission_granted = false
    authorised_features.each do |permitted_thing|
      if (the_user_group.system_requirements_access && permitted_thing == 'system_requirements_access') ||
         (the_user_group.content_management_access && permitted_thing == 'content_management_access') ||
         (the_user_group.stripe_management_access && permitted_thing == 'stripe_management_access') ||
         (the_user_group.user_management_access && permitted_thing == 'user_management_access') ||
         (the_user_group.developer_access && permitted_thing == 'developer_access') ||
         (the_user_group.marketing_resources_access && permitted_thing == 'marketing_resources_access') ||
         (the_user_group.student_user && the_user_group.trial_or_sub_required && permitted_thing == 'student_user') ||
         (!the_user_group.student_user && permitted_thing == 'non_student_user') ||
         (the_user_group.user_group_management_access && permitted_thing == 'user_group_management_access')
        permission_granted = true
      end
    end
    unless permission_granted
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
      false
    end
  end
  helper_method :ensure_user_has_access_rights


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

    #TODO These are being filled with ConstructedResponse JSON in courses_controller tests (L125)
    #cookies.encrypted[:first_session_landing_url] ||= {value: request.filtered_path, httponly: true}
    #cookies.encrypted[:latest_session_landing_url] ||= {value: request.filtered_path, httponly: true}
    #cookies.encrypted[:post_sign_up_redirect_path] ||= {value: nil, httponly: true}
  end

  def reset_latest_session_landing_url
    cookies.encrypted[:latest_session_landing_url] = {value: request.filtered_path, httponly: true}
  end

  def reset_post_sign_up_redirect_path(new_path)
    cookies.encrypted[:post_sign_up_redirect_path] = {value: new_path, httponly: true} if new_path
  end

  def drop_referral_code_cookie(referral_code)
    referral_data = request.referrer ? "#{referral_code.code};#{request.referrer}" : referral_code.code

    # Browsers do not send back cookie attributes so we cannot update only value
    # without altering expiration date. Therefore if we detect difference between
    # current referral data and data stored in the cookie we will always save new
    # data and set expiration to next 30 days.
    if referral_code && referral_data != cookies.encrypted[:referral_data]
      cookies.encrypted[:referral_data] = { value: referral_data, expires: 30.days.from_now, httponly: true }
    end

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

  # content management links (non-student)
  def course_module_special_link(the_thing)
    # used for tutor-facing links

    if the_thing.class == CourseModuleElement && !the_thing.id.nil?
        edit_course_module_element_url(the_thing.id)

    elsif the_thing.class == CourseModule
      subject_course_url(
                the_thing.subject_course)

    elsif the_thing.class == CourseSection
      subject_course_url(
          the_thing.subject_course)

    elsif the_thing.class == SubjectCourse
      new_course_modules_for_subject_course_and_name_url(the_thing.name_url)

    elsif the_thing.class == ContentPage
      content_pages_url

    else # default route
      subject_course_url
    end
  end
  helper_method :course_module_special_link


  def content_activation_special_link(the_thing)
    if the_thing.class == CourseModuleElement || the_thing.class == CourseModule
      subject_course_url(the_thing.course_module.subject_course)
    elsif the_thing.class == SubjectCourse
      subject_course_url
    elsif the_thing.class == ContentPage
      content_pages_url
    elsif the_thing.class == SubjectCourseResource
      course_resources_url(the_thing.subject_course)
    else
      subject_course_url
    end
  end
  helper_method :content_activation_special_link



  # Library Navigation Links
  def library_special_link(the_thing)
    if the_thing.class == Group
      the_thing = the_thing
      library_group_url(
                  the_thing.name_url
      )
    elsif the_thing.class == SubjectCourse
      the_thing = the_thing
      if the_thing.parent
        if the_thing.preview
          library_preview_url(
              the_thing.parent.name_url,
              the_thing.name_url
          )
        else
          library_course_url(
              the_thing.parent.name_url,
              the_thing.name_url
          )
        end
      else
        library_url
      end
    elsif the_thing.class == CourseModule
      the_thing = the_thing
      library_course_url(
          the_thing.parent.parent.name_url,
          the_thing.parent.name_url
      )
    else
      library_url
    end
  end
  helper_method :library_special_link

  # Library Navigation Links
  def navigation_special_link(the_thing)
    the_thing = the_thing
    library_course_url(
        the_thing.course_module.course_section.subject_course.group.name_url,
        the_thing.course_module.course_section.subject_course.name_url,
        anchor: the_thing.course_module.course_section.name_url,
        cm: the_thing.course_module.id
    )
  end
  helper_method :navigation_special_link


  def course_special_link(the_thing, scul=nil)
    if the_thing.class == SubjectCourse
      library_course_url(
          the_thing.parent.name_url,
          the_thing.name_url
      )
    elsif the_thing.class == CourseSection
      library_course_url(
          the_thing.subject_course.group.name_url,
          the_thing.subject_course.name_url,
          anchor: the_thing.name_url
      )
    elsif the_thing.class == CourseModule
      library_course_url(
          the_thing.course_section.subject_course.group.name_url,
          the_thing.course_section.subject_course.name_url,
          the_thing.course_section.name_url,
          anchor: the_thing.name_url
      )
    elsif the_thing.class == CourseModuleElement
      if current_user
        permission = the_thing.available_to_user(current_user, scul)
        if permission[:view]
          course_url(
              the_thing.course_module.course_section.subject_course.name_url,
              the_thing.course_module.course_section.name_url,
              the_thing.course_module.name_url,
              the_thing.name_url
          )

        else
          library_course_url(
              the_thing.course_module.course_section.subject_course.group.name_url,
              the_thing.course_module.course_section.subject_course.name_url,
              anchor: permission[:reason]
          )
        end
      else
        new_student_url
      end

    else
      library_special_link(the_thing)
    end
  end
  helper_method :course_special_link

  def course_resource_special_link(the_thing)
    if the_thing.class == SubjectCourseResource

      if current_user
        permission = the_thing.available_to_user(current_user)
        if permission[:view]
          the_thing.external_url.blank? ? the_thing.file_upload.url : the_thing.external_url
        else
          library_course_url(
              the_thing.subject_course.group.name_url,
              the_thing.subject_course.name_url,
              anchor: permission[:reason]
          )
        end
      else
        new_student_url
      end

    else
      library_special_link(the_thing)
    end
  end
  helper_method :course_resource_special_link

  def seo_title_maker(seo_title, seo_description, seo_no_index)
    @seo_title = seo_title.to_s.truncate(65) || 'ACCA: Professional Accountancy Courses Online| LearnSignal'
    @seo_description = seo_description.to_s.truncate(156)
    @seo_no_index = seo_no_index
  end

  def tag_manager_data_layer(course)
    @tag_manager_course = course
  end
  helper_method :tag_manager_data_layer

  def setup_mcapi
    @mc = Mailchimp::API.new(ENV['LEARNSIGNAL_MAILCHIMP_API_KEY'])
  end


end
