class EnrollmentEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, enrollment_id, datetime_triggered, method_name, *template_args)
    @user = User.where(email: email).first
    @enrollment = Enrollment.find(enrollment_id)
    @corporate = nil
    if @user && @user.email && @user.individual_student?
      if !@enrollment.subject_course_user_log.completed && (@enrollment.updated_at.to_i < datetime_triggered + 2.hours.to_i)
        mc = MandrillClient.new(@user, @corporate)
        mc.send(method_name, *template_args)
      end
    end
  end

end
