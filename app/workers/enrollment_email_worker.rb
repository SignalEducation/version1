class EnrollmentEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, scul_id, datetime_triggered, method_name)
    @user = User.where(email: email).first
    @course_log = CourseLog.find(scul_id)
    @course = @course_log.course
    @enrollment = @course_log.active_enrollment
    @url =
      if @course_log.last_element.next_element.class == CourseStep
        UrlHelper.instance.show_course_url(course_name_url: @course.name_url, course_lesson_name_url: @course_log.last_element.course_lesson.name_url, course_step_name_url: @course_log.last_element.next_element.name_url, host: ENV['LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN'])
      else
        UrlHelper.instance.library_course_url(group_name_url: @course.parent.name_url, course_name_url: @course.name_url, host: ENV['LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN'])
      end

    template_args = [@url, @course.name]
    return unless @user&.email && @user.student_user? && @enrollment
    return unless !@course_log.completed && (@enrollment.updated_at.to_i < datetime_triggered + 2.hours.to_i)

    MandrillClient.new(@user).send(method_name, *template_args)
  end
end
