require 'mailchimp'
require 'prawn'
require 'mandrill'
require 'csv'
require 'will_paginate/array'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true
  before_action :authenticate_if_staging
  before_action :setup_mcapi
  before_action :set_locale        # not for Api::
  before_action :set_session_stuff # not for Api::
  before_action :set_layout_variables
  before_action :authorize_rack_profiler

  helper_method :current_user_session, :current_user

  Time::DATE_FORMATS[:simple]   = I18n.t('controllers.application.datetime_formats.simple')
  Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.datetime_formats.standard')
  Date::DATE_FORMATS[:simple]   = I18n.t('controllers.application.date_formats.simple')
  Date::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')

  EXCLUDED_CONTROLLERS = %w[orders subscriptions].freeze

  ### User access control and authentication

  def current_user_session
    return @current_user_session if defined?(@current_user_session)

    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session&.record
  end

  def set_current_visit
    return unless current_visit && !current_visit.user

    current_visit.user = current_user
    current_visit.save!
  end

  def set_layout_variables
    @layout = 'standard'
    @navbar = 'standard'
    @top_margin = true
    @footer = 'standard'
    @groups = Group.all_active.with_active_body.all_in_order
    @footer_content_pages = ContentPage.for_footer
    @footer_landing_pages = HomePage.for_footer
    navbar_links = %w[about-us testimonials resources]
    @navbar_landing_pages = HomePage.where(public_url: navbar_links)

    return if ExternalBanner::BANNER_CONTROLLERS.exclude?(controller_name)

    @banner = ExternalBanner.all_without_parent.render_for(controller_name).all_in_order.first
  end

  def logged_in_required
    return if current_user

    session[:return_to] = request.original_url
    flash[:error] = I18n.t('controllers.application.logged_in_required.flash_error')
    redirect_to sign_in_url
    false
  end

  def logged_out_required
    return unless current_user

    flash[:error] = I18n.t('controllers.application.logged_out_required.flash_error')
    redirect_to root_url
    false
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    destination = session[:return_to] || default
    session[:return_to] = nil

    redirect_to(destination, flash: { just_signed_in: true })
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
         (the_user_group.user_group_management_access && permitted_thing == 'user_group_management_access') ||
         (the_user_group.exercise_corrections_access && permitted_thing == 'exercise_corrections_access')
        permission_granted = true
      end
    end

    return if permission_granted

    flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    redirect_to root_url
    false
  end
  helper_method :ensure_user_has_access_rights

  def authenticate_if_staging
    return unless Rails.env.staging? && %w[stripe_v02 paypal_webhooks].exclude?(controller_name)

    authenticate_or_request_with_http_basic 'Staging' do |name, password|
      name == 'signal' && password == '27(South!)'
    end
  end

  def authorize_rack_profiler
    return unless current_user&.is_admin?

    Rack::MiniProfiler.authorize_request
  end

  #### Locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    Rails.logger.debug "DEBUG: ApplicationController#default_url_options: Received options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

  #### Session GUIDs and user tracking

  def current_session_guid
    cookies.encrypted[:session_guid]
  end

  helper_method :current_session_guid

  def set_session_stuff
    cookies.encrypted[:session_guid] ||= { value: ApplicationController.generate_random_code(64), httponly: true }

    # TODO, These are being filled with ConstructedResponse JSON in courses_controller tests (L125)
    # cookies.encrypted[:first_session_landing_url] ||= {value: request.filtered_path, httponly: true}
    # cookies.encrypted[:latest_session_landing_url] ||= {value: request.filtered_path, httponly: true}
    # cookies.encrypted[:post_sign_up_redirect_path] ||= {value: nil, httponly: true}
  end

  def reset_latest_session_landing_url
    cookies.encrypted[:latest_session_landing_url] = { value: request.filtered_path, httponly: true }
  end

  def reset_post_sign_up_redirect_path(new_path)
    cookies.encrypted[:post_sign_up_redirect_path] = { value: new_path, httponly: true } if new_path
  end

  def drop_referral_code_cookie(referral_code)
    referral_data = request.referrer ? "#{referral_code.code};#{request.referrer}" : referral_code.code

    # Browsers do not send back cookie attributes so we cannot update only value
    # without altering expiration date. Therefore if we detect difference between
    # current referral data and data stored in the cookie we will always save new
    # data and set expiration to next 30 days.
    return unless referral_code && referral_data != cookies.encrypted[:referral_data]

    cookies.encrypted[:referral_data] = { value: referral_data, expires: 30.days.from_now, httponly: true }
  end

  #### General purpose code

  def self.generate_random_code(number_of_characters = 20)
    possible_characters = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    the_answer = ''
    possible_character_size = possible_characters.size
    number_of_characters.times do
      the_answer << possible_characters[rand(possible_character_size)]
    end

    the_answer
  end

  def self.generate_random_number(number_of_characters = 5)
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
    case the_thing
    when CourseModule, CourseSection
      subject_course_url(the_thing.subject_course)
    when SubjectCourse
      new_course_modules_for_subject_course_and_name_url(the_thing.name_url)
    when ContentPage
      content_pages_url
    when CourseModuleElement
      the_thing.id.present? ? edit_course_module_element_url(the_thing.id) : subject_course_url
    else
      subject_course_url
    end
  end

  helper_method :course_module_special_link

  def content_activation_special_link(the_thing)
    case the_thing
    when CourseModuleElement, CourseModule
      subject_course_url(the_thing.course_module.subject_course)
    when SubjectCourse
      subject_course_url
    when ContentPage
      content_pages_url
    when SubjectCourseResource
      course_resources_url(the_thing.subject_course)
    else
      subject_course_url
    end
  end

  helper_method :content_activation_special_link

  # Library Navigation Links
  def library_special_link(the_thing)
    case the_thing
    when Group
      library_group_url(the_thing.name_url)
    when SubjectCourse
      the_thing.parent ? library_course_url(the_thing.parent.name_url, the_thing.name_url) : library_url
    when CourseModule
      library_course_url(the_thing.parent.parent.name_url, the_thing.parent.name_url)
    else
      library_url
    end
  end

  helper_method :library_special_link

  # Enrollment Navigation Links
  def course_enrollment_special_link(course_id)
    subject_course = SubjectCourse.where(id: course_id).first

    if subject_course&.active
      library_course_url(subject_course.parent.name_url,
                         subject_course.name_url,
                         anchor: :bootcamp)
    else
      student_dashboard_url
    end
  end

  helper_method :course_enrollment_special_link

  # Library Navigation Links
  def navigation_special_link(the_thing)
    library_course_url(the_thing.course_module.course_section.subject_course.group.name_url,
                       the_thing.course_module.course_section.subject_course.name_url,
                       anchor: the_thing.course_module.course_section.name_url,
                       cm: the_thing.course_module.id)
  end

  helper_method :navigation_special_link

  def course_special_link(the_thing, scul = nil)
    case the_thing
    when SubjectCourse
      library_course_url(the_thing.parent.name_url, the_thing.name_url)
    when CourseSection
      library_course_url(the_thing.subject_course.group.name_url,
                         the_thing.subject_course.name_url,
                         anchor: the_thing.name_url)
    when CourseModule
      library_course_url(the_thing.course_section.subject_course.group.name_url,
                         the_thing.course_section.subject_course.name_url,
                         the_thing.course_section.name_url,
                         anchor: the_thing.name_url)
    when CourseModuleElement
      user_course_correct_url(the_thing, scul)
    else
      library_special_link(the_thing)
    end
  end

  helper_method :course_special_link

  def user_course_correct_url(the_thing, scul = nil)
    return new_student_url unless current_user

    if current_user.non_verified_user? # current_user.non_verified_user?
      library_course_url(the_thing.course_module.course_section.subject_course.group.name_url,
                         the_thing.course_module.course_section.subject_course.name_url,
                         anchor: 'verification-required')

    elsif the_thing.related_course_module_element_id && the_thing.previous_cme_restriction(scul)
      library_course_url(the_thing.course_module.course_section.subject_course.group.name_url,
                         the_thing.course_module.course_section.subject_course.name_url,
                         anchor: 'related-lesson-restriction')
    else
      course_url(the_thing.course_module.course_section.subject_course.name_url,
                 the_thing.course_module.course_section.name_url,
                 the_thing.course_module.name_url,
                 the_thing.name_url)
    end
  end

  def course_resource_special_link(the_thing)
    if the_thing.class == SubjectCourseResource
      the_thing.external_url.presence || the_thing.file_upload.url
    else
      library_special_link(the_thing)
    end
  end

  helper_method :course_resource_special_link

  def subscription_checkout_special_link(exam_body_id, subscription_plan_guid = nil)
    if current_user
      new_subscription_url(exam_body_id: exam_body_id, plan_guid: subscription_plan_guid)
    else
      sign_in_or_register_url(exam_body_id: exam_body_id, plan_guid: subscription_plan_guid)
    end
  end

  helper_method :subscription_checkout_special_link

  def product_checkout_special_link(exam_body_id, product_id = nil)
    if current_user
      new_order_url(product_id)
    else
      sign_in_or_register_url(exam_body_id: exam_body_id, product_id: product_id)
    end
  end

  helper_method :product_checkout_special_link

  def seo_title_maker(seo_title, seo_description, seo_no_index)
    @seo_title = seo_title.to_s.truncate(65) || 'Professional Finance Courses Online| LearnSignal'
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
