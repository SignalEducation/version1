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

  before_action :use_basic_auth_for_staging

  def use_basic_auth_for_staging
    if Rails.env.staging? && !request.original_fullpath.include?('/api/')
      ApplicationController.http_basic_authenticate_with name: 'signal', password: 'MeagherMacRedmond'
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale        # not for Api::
  before_action :set_session_stuff # not for Api::
  before_action :log_user_activity # not for Api::

  helper_method :current_user_session, :current_user

  Time::DATE_FORMATS[:simple] = I18n.t('controllers.application.datetime_formats.simple')
  Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.datetime_formats.standard')
  Date::DATE_FORMATS[:simple] = I18n.t('controllers.application.date_formats.simple')
  Date::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')

  ### User access control and authentication

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
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
         (the_user_group.forum_manager      && permitted_thing == 'forum_manager') ||
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

  def paywall_checkpoint(cme_position, is_a_jumbo_quiz)
    number_of_free_cmes_allowed = -1
    allowed     = {course_content: {view_all: true, reason: nil},
                   forum: {read: true, write: true},
                   blog: {comment: true} }
    not_allowed = {course_content: {view_all: false, reason: ''},
                   forum: {read: true, write: false},
                   blog: {comment: false} }
    if current_user.nil? && (cme_position.to_i > number_of_free_cmes_allowed || is_a_jumbo_quiz)
      result = not_allowed
      result[:course_content][:reason] = 'not_logged_in'
    elsif !current_user.user_group.subscription_required_to_see_content
      result = allowed
    elsif %w(trialing active canceled-pending).include?(current_user.subscriptions.all_in_order.last.try(:current_status) || 'canceled')
      result = allowed
    else
      result = not_allowed
      result[:course_content][:reason] = 'account_' + (current_user.subscriptions.all_in_order.last.try(:current_status) || 'canceled')
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
    @mathjax_required = false # default
    @show_mixpanel = (Rails.env.staging? || Rails.env.production?) && (!current_user || current_user.try(:individual_student?))
  end

  def reset_latest_session_landing_url
    cookies.encrypted[:latest_session_landing_url] = {value: request.filtered_path, httponly: true}
  end

  def reset_post_sign_up_redirect_path(new_path)
    cookies.encrypted[:post_sign_up_redirect_path] = {value: new_path, httponly: true} if new_path
  end

  def log_user_activity
    UserLoggerWorker.perform_async(   ApplicationController.generate_random_code(24),
            current_user.try(:id),    current_session_guid,
            request.filtered_path,    controller_name,
            action_name,              request.filtered_parameters,
            request.remote_ip,        request.env['HTTP_USER_AGENT'],
            cookies.encrypted[:first_session_landing_url],
            cookies.encrypted[:latest_session_landing_url],
            cookies.permanent.encrypted[:post_sign_up_redirect_path]
    )
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

  # tutor/admin-facing
  def course_module_special_link(the_thing)
    # used for tutor-facing links

    if the_thing.class == CourseModuleElement && !the_thing.id.nil?
        edit_course_module_element_url(the_thing.id)

    elsif the_thing.class == CourseModule && !the_thing.id.nil?
      if the_thing.exam_section_id
        course_modules_for_qualification_exam_level_exam_section_and_name_url(
                the_thing.exam_level.qualification.name_url,
                the_thing.exam_level.name_url,
                the_thing.exam_section.try(:name_url) || 'all',
                the_thing.name_url)
      else
        course_modules_for_qualification_exam_level_exam_section_and_name_url(
                the_thing.exam_level.qualification.name_url,
                the_thing.exam_level.name_url,
                'all',
                the_thing.name_url)
      end

    elsif the_thing.class == ExamSection
      course_modules_for_qualification_exam_level_and_exam_section_url(
              the_thing.exam_level.qualification.name_url,
              the_thing.exam_level.name_url,
              the_thing.name_url)

    elsif the_thing.class == ExamLevel
      course_modules_for_qualification_and_exam_level_url(
              the_thing.qualification.name_url,
              the_thing.name_url)

    elsif the_thing.class == Qualification
      course_modules_for_qualification_url(the_thing.name_url)

    else # default route
      course_modules_url
    end
  end
  helper_method :course_module_special_link

  # customer-facing
  def library_special_link(the_thing, direction='forwards')
    the_thing = the_thing
    if direction == 'forwards'

      until the_thing.try(:active_children).try(:count) != 1 || (the_thing.class == CourseModuleElement || the_thing.class == CourseModule || the_thing.class == ExamLevel || the_thing.class == ExamSection)
        if the_thing.active_children.count == 1 &&
                       (the_thing.active_children.first.class == SubjectArea ||
                        the_thing.active_children.first.class == Institution ||
                        the_thing.active_children.first.class == Qualification ||
                        the_thing.active_children.first.class == ExamLevel ||
                        the_thing.active_children.first.class == ExamSection)
          the_thing = the_thing.active_children.first
        end
      end

    else

      until the_thing.class == SubjectArea || the_thing.try(:active_children).try(:count).to_i > 1
        if the_thing.try(:active_children).try(:count).to_i == 1
          the_thing = the_thing.parent
        end
      end
    end

    if the_thing.class == CourseModule || the_thing.class == CourseModuleElement
      course_special_link(the_thing)
    elsif the_thing.class == ExamSection
      library_url(the_thing.exam_level.qualification.institution.subject_area.name_url,
                  the_thing.exam_level.qualification.institution.name_url,
                  the_thing.exam_level.qualification.name_url,
                  the_thing.exam_level.name_url
      )
    elsif the_thing.class == ExamLevel
      library_url(the_thing.qualification.institution.subject_area.name_url,
                  the_thing.qualification.institution.name_url,
                  the_thing.qualification.name_url,
                  the_thing.name_url
      )
    elsif the_thing.class == Qualification
      library_url(the_thing.institution.subject_area.name_url,
                  the_thing.institution.name_url,
                  the_thing.name_url
      )
    elsif the_thing.class == Institution
      library_url(the_thing.subject_area.name_url,
                  the_thing.name_url
      )
    elsif the_thing.class == SubjectArea
      library_url(the_thing.name_url)
    else
      library_url
    end
  end
  helper_method :library_special_link

  def course_special_link(the_thing, direction='forwards')
    if the_thing.class == CourseModule
      course_url(
              the_thing.exam_level.qualification.institution.subject_area.name_url,
              the_thing.exam_level.qualification.institution.name_url,
              the_thing.exam_level.qualification.name_url,
              the_thing.exam_level.name_url,
              the_thing.exam_section.try(:name_url) || 'all',
              the_thing.name_url
      )
    elsif the_thing.class == CourseModuleElement || the_thing.class == CourseModuleJumboQuiz
      course_url(
              the_thing.course_module.exam_level.qualification.institution.subject_area.name_url,
              the_thing.course_module.exam_level.qualification.institution.name_url,
              the_thing.course_module.exam_level.qualification.name_url,
              the_thing.course_module.exam_level.name_url,
              the_thing.course_module.exam_section.try(:name_url) || 'all',
              the_thing.course_module.name_url,
              the_thing.name_url
      )
    else
      # shouldn't be here - re-route to /library/bla-bla
      library_special_link(the_thing, direction)
    end
  end
  helper_method :course_special_link

  def seo_title_maker(last_element, seo_description, seo_no_index)
    @seo_title = last_element ?
            "LearnSignal – #{last_element.to_s.truncate(46)}" :
            'LearnSignal'
    @seo_description = seo_description
    @seo_no_index = seo_no_index
  end

end
