class FreeTrialEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, method_name, *template_args)
    @user = User.where(email: email).first
    @corporate = nil
    if @user && @user.email && @user.student_user_type_id == StudentUserType.default_free_trial_user_type.id
      mc = MandrillClient.new(@user, @corporate)
      mc.send(method_name, *template_args)
    end
  end

end
