require 'mailchimp'
require 'prawn'
require 'mandrill'
require 'csv'
require 'will_paginate/array'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :reset_session, prepend: true
  before_action :authenticate_if_staging
  before_action :set_locale        # not for Api::
  before_action :set_session_stuff # not for Api::
  before_action :set_layout_variables
  # before_action :authorize_rack_profiler

  helper_method :current_user_session, :current_user

  Time::DATE_FORMATS[:simple]   = I18n.t('controllers.application.datetime_formats.simple')
  Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.datetime_formats.standard')
  Date::DATE_FORMATS[:simple]   = I18n.t('controllers.application.date_formats.simple')
  Date::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')

  EXCLUDED_CONTROLLERS = %w[orders subscriptions].freeze

  rescue_from ActionController::InvalidAuthenticityToken, with: :log_in_airbrake

  ### User access control and authentication

  def current_user_session
    return @current_user_session if defined?(@current_user_session)

    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session&.record
  end

  def log_out_user
    current_user_session&.destroy
    redirect_to sign_in_path
  end

  def reset_session
    super
  end

  def log_in_airbrake(error)
    Airbrake.notify(error)
    Appsignal.send_error(error)
    true
  end

  def set_current_visit(session_user = nil)
    return unless current_visit && !current_visit.user

    current_visit.user = current_user || session_user
    current_visit.save!
  end

  def set_layout_variables
    @layout ||= 'standard'
    @navbar = 'standard'
    @top_margin = true
    @footer = 'white'
    @chat   = true
    @groups = Group.includes(:exam_body).all_active.with_active_body.all_in_order
    @footer_content_pages = ContentPage.all_active.for_footer
    @footer_landing_pages = HomePage.for_footer
    navbar_links = %w[about-us testimonials resources]
    @navbar_landing_pages = HomePage.where(public_url: navbar_links)

    return unless current_user&.preferred_exam_body && current_user&.standard_student_user?

    @banner =
      if current_user.valid_access_for_exam_body?(current_user.preferred_exam_body_id, current_user.preferred_group_id)
        ExternalBanner.all_active.
          for_exam_body(current_user.preferred_exam_body).
          for_paid.all_in_order.first
      else
        ExternalBanner.all_active.
          for_exam_body(current_user.preferred_exam_body).
          for_basic.all_in_order.first
      end
    @exam_body = ExamBody.find(@banner.exam_body_id) if @banner
  end

  def management_layout
    @layout = 'management'
  end

  def student_sidebar_layout
    @layout = 'student_sidebar'
  end

  def logged_in_required
    return if current_user

    session[:return_to] = request.original_url
    redirect_to sign_in_url
    false
  end

  def logged_out_required
    return unless current_user

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
    return unless Rails.env.staging? && %w[stripe_webhooks paypal_webhooks cron_tasks messages].exclude?(controller_name)

    authenticate_or_request_with_http_basic 'Staging' do |name, password|
      name == 'signal' && password == '27(South!)'
    end
  end

  def authorize_rack_profiler
    return unless current_user&.admin?

    Rack::MiniProfiler.authorize_request
  end

  #### Locale

  def set_locale
    I18n.locale = I18n.default_locale
  end

  def default_url_options(options = {})
    { :locale => I18n.locale == I18n.default_locale ? nil : I18n.locale  }
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

  def vimeo_as_main?
    SystemSetting.find_by(environment: Rails.env).settings['vimeo_as_main_player?'].to_bool
  rescue NoMethodError => e
    Airbrake::AirbrakeLogger.new(logger).error(e.message)
    Appsignal.send_error(e)
    true
  end

  # content management links (non-student)
  def course_lesson_special_link(the_thing)
    # used for tutor-facing links
    case the_thing
    when CourseLesson, CourseSection
      course_url(the_thing.course)
    when Course
      new_course_lessons_for_course_and_name_url(the_thing.name_url)
    when ContentPage
      content_pages_url
    when CourseStep
      the_thing.id.present? ? edit_admin_course_step_url(the_thing.id) : course_url
    else
      course_url
    end
  end

  helper_method :course_lesson_special_link

  def content_activation_special_link(the_thing)
    case the_thing
    when CourseStep, CourseLesson
      course_url(the_thing.course_lesson.course)
    when Course
      course_url
    when ContentPage
      content_pages_url
    when CourseResource
      admin_course_resources_url(the_thing.course)
    else
      course_url
    end
  end

  helper_method :content_activation_special_link

  # Library Navigation Links
  def library_special_link(the_thing)
    case the_thing
    when Group
      if the_thing.gcu?
        course = the_thing.courses.all_active.last
        library_course_url(course.parent.name_url, course.name_url)
      else
        library_group_url(the_thing.name_url)
      end
    when Course
      the_thing.parent ? library_course_url(the_thing.parent.name_url, the_thing.name_url) : library_url
    when CourseLesson
      library_course_url(the_thing.parent.parent.name_url, the_thing.parent.name_url)
    else
      library_url
    end
  end

  helper_method :library_special_link

  # Enrollment Navigation Links
  def course_enrollment_special_link(course_id)
    course = Course.where(id: course_id).first

    if course&.active
      library_course_url(course.parent.name_url,
                         course.name_url,
                         anchor: :bootcamp)
    else
      student_dashboard_url
    end
  end

  helper_method :course_enrollment_special_link

  # Library Navigation Links
  def navigation_special_link(the_thing)
    library_course_url(the_thing.course_lesson.course_section.course.group.name_url,
                       the_thing.course_lesson.course_section.course.name_url,
                       anchor: the_thing.course_lesson.course_section.name_url,
                       cm: the_thing.course_lesson.id)
  end

  helper_method :navigation_special_link

  def course_special_link(the_thing, scul = nil)
    case the_thing
    when Course
      library_course_url(the_thing.parent.name_url, the_thing.name_url)
    when CourseSection
      library_course_url(the_thing.course.group.name_url,
                         the_thing.course.name_url,
                         anchor: the_thing.name_url)
    when CourseLesson
      library_course_url(the_thing.course_section.course.group.name_url,
                         the_thing.course_section.course.name_url)
    when CourseStep
      user_course_correct_url(the_thing, scul)
    else
      library_special_link(the_thing)
    end
  end

  helper_method :course_special_link

  def user_course_correct_url(the_thing, scul = nil)
    return new_student_url unless current_user

    if current_user.show_verify_email_message? && current_user.verify_remain_days.zero? && !current_user.valid_subscription?
      library_course_url(the_thing.course_lesson.course_section.course.group.name_url,
                         the_thing.course_lesson.course_section.course.name_url,
                         anchor: 'verification-required')
    elsif the_thing.related_course_step_id && the_thing.previous_cme_restriction(scul)
      library_course_url(the_thing.course_lesson.course_section.course.group.name_url,
                         the_thing.course_lesson.course_section.course.name_url,
                         anchor: 'related-lesson-restriction')
    else
      show_course_url(the_thing.course_lesson.course_section.course.name_url,
                      the_thing.course_lesson.course_section.name_url,
                      the_thing.course_lesson.name_url,
                      the_thing.name_url)
    end
  end
  helper_method :user_course_correct_url

  def course_resource_special_link(the_thing)
    if the_thing.class == CourseResource
      the_thing.external_url.presence || the_thing.file_upload.url
    else
      library_special_link(the_thing)
    end
  end

  helper_method :course_resource_special_link

  def subscription_checkout_special_link(exam_body_id, subscription_plan_guid = nil, login_only = nil)
    if current_user
      new_subscription_url(exam_body_id: exam_body_id, plan_guid: subscription_plan_guid)
    elsif login_only
      sign_in_checkout_url(exam_body_id: exam_body_id, plan_guid: subscription_plan_guid)
    else
      sign_in_or_register_url(exam_body_id: exam_body_id, plan_guid: subscription_plan_guid)
    end
  end

  helper_method :subscription_checkout_special_link

  def product_checkout_special_link(exam_body_id, product_id = nil, login_only = nil)
    if current_user
      new_product_order_url(product_id)
    elsif login_only
      sign_in_checkout_url(exam_body_id: exam_body_id, product_id: product_id)
    else
      sign_in_or_register_url(exam_body_id: exam_body_id, product_id: product_id)
    end
  end

  helper_method :product_checkout_special_link

  def seo_title_maker(seo_title, seo_description, seo_no_index)
    @seo_title = seo_title.to_s.truncate(65) || 'Professional Finance Courses Online| Learnsignal'
    @seo_description = seo_description.to_s.truncate(156)
    @seo_no_index = seo_no_index
  end

  def tag_manager_data_layer(course)
    @tag_manager_course = course
  end
  helper_method :tag_manager_data_layer
end
