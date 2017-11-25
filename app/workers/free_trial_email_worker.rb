class FreeTrialEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'medium'

  def perform(email, method_name, *template_args)
    @user = User.where(email: email).first
    if @user && @user.email && @user.trial_user?
      mc = MandrillClient.new(@user)
      mc.send(method_name, *template_args)
    end
  end

end
