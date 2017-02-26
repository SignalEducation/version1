class EnrollmentEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, scul_id, datetime_triggered, method_name)
    @user = User.where(email: email).first
    @subject_course_user_log = SubjectCourseUserLog.find(scul_id)
    @enrollment = @subject_course_user_log.enrollment
    @course_name = @subject_course_user_log.subject_course.name
    if @subject_course_user_log.last_element.next_element.class == CourseModuleElement
      @url = Rails.application.routes.url_helpers.course_url(subject_course_name_url: @subject_course_user_log.subject_course.name_url, course_module_name_url: @subject_course_user_log.last_element.course_module.name_url, course_module_element_name_url: @subject_course_user_log.last_element.next_element.name_url, host: ENV['learnsignal_v3_server_email_domain'])
    else
      @url = Rails.application.routes.url_helpers.subscription_course_url(subject_course_name_url: @subject_course_user_log.subject_course.name_url, host: Rails.env.test? ? "www.example.com" : Rails.application.routes.default_url_options[:host])
    end


    template_args = [@url, @course_name]
    if @user && @user.email && @user.individual_student?
      if !@subject_course_user_log.completed && (@enrollment.updated_at.to_i < datetime_triggered + 2.hours.to_i)
        mc = MandrillClient.new(@user)
        mc.send(method_name, *template_args)
      end
    end
  end

end
