class EnrollmentEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, enrollment_id, datetime_triggered, method_name, *template_args)
    @user = User.where(email: email).first
    @enrollment = Enrollment.find(enrollment_id)
    @corporate = nil
    if @user && @user.email && @user.student_user_type_id == StudentUserType.default_free_trial_user_type.id
      if @enrollment.subject_course_user_log.("percentage_complete < 100") && !@enrollment.updated_at > datetime_triggered + 2.hours
        mc = MandrillClient.new(@user, @corporate)
        mc.send(method_name, *template_args)
      end
    end
  end

end
