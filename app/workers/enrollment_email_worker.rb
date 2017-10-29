class EnrollmentEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, scul_id, datetime_triggered, method_name)
    @user = User.where(email: email).first
    @subject_course_user_log = SubjectCourseUserLog.find(scul_id)
    @course = @subject_course_user_log.subject_course
    @enrollment = @subject_course_user_log.enrollment

    if @subject_course_user_log.last_element.next_element.class == CourseModuleElement
      @url = Rails.application.routes.url_helpers.course_url(subject_course_name_url: @course.name_url, course_module_name_url: @subject_course_user_log.last_element.course_module.name_url, course_module_element_name_url: @subject_course_user_log.last_element.next_element.name_url, host: ENV['LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN'])
    else
      @url = Rails.application.routes.url_helpers.library_course_url(group_name_url: @course.parent.name_url, subject_course_name_url: @course.name_url, host: ENV['LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN'])
    end


    template_args = [@url, @course.name]
    if @user && @user.email && @user.individual_student?
      if !@subject_course_user_log.completed && (@enrollment.updated_at.to_i < datetime_triggered + 2.hours.to_i)
        mc = MandrillClient.new(@user)
        mc.send(method_name, *template_args)
      end
    end
  end

end
