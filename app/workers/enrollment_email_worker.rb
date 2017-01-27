class EnrollmentEmailWorker
  include Sidekiq::Worker
  delegate :url_helpers, to: 'Rails.application.routes'
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, scul_id, datetime_triggered, method_name)
    @user = User.where(email: email).first
    @subject_course_user_log = SubjectCourseUserLog.find(scul_id)
    @enrollment = @subject_course_user_log.enrollment
    @corporate = nil
    @course_name = @subject_course_user_log.subject_course.name
    if @subject_course_user_log.last_element.next_element.class == CourseModuleElement
      @url = url_helpers.course_path(subject_course_name_url: @subject_course_user_log.subject_course.name_url, course_module_name_url: @subject_course_user_log.last_element.course_module.name_url, course_module_element_name_url: @subject_course_user_log.last_element.next_element.name_url, host: Rails.env.test? ? "www.example.com" : Rails.application.routes.default_url_options[:host])
    else
      if @subject_course_user_log.subject_course.subject_course_category == SubjectCourseCategory.default_subscription_category
        @url = url_helpers.subscription_course_url(subject_course_name_url: @subject_course_user_log.subject_course.name_url, host: Rails.env.test? ? "www.example.com" : Rails.application.routes.default_url_options[:host])
      else
        @url = url_helpers.diploma_course_url(subject_course_name_url: @subject_course_user_log.subject_course.name_url, host: Rails.env.test? ? "www.example.com" : Rails.application.routes.default_url_options[:host])
      end
    end


    template_args = [@url, @course_name]
    if @user && @user.email && @user.individual_student?
      if !@subject_course_user_log.completed && (@enrollment.updated_at.to_i < datetime_triggered + 2.hours.to_i)
        mc = MandrillClient.new(@user, @corporate)
        mc.send(method_name, *template_args)
      end
    end
  end

end
