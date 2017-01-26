class EnrollmentEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, scul_id, datetime_triggered, method_name)
    @user = User.where(email: email).first
    @subject_course_user_log = SubjectCourseUserLog.find(scul_id)
    @enrollment = @subject_course_user_log.enrollment
    @corporate = nil
    @course_name = @subject_course_user_log.subject_course.name
    @url = Rails.application.routes.url_helpers.course_url(host: Rails.application.routes.default_url_options[:host], subject_course_name_url: @subject_course_user_log.subject_course.name_url, course_module_name_url: @subject_course_user_log.last_element.next_element.course_module.name_url, course_module_element_name_url: @subject_course_user_log.last_element.next_element.name_url)

    template_args = [@url, @course_name]
    if @user && @user.email && @user.individual_student?
      if !@subject_course_user_log.completed && (@enrollment.updated_at.to_i < datetime_triggered + 2.hours.to_i)
        mc = MandrillClient.new(@user, @corporate)
        mc.send(method_name, *template_args)
      end
    end
  end

end
