class ReferralsWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'low'

  def perform(user_id, method_name, *template_args)
    @user = User.find_by_id(user_id)
    if @user && @user.email
      mc = MandrillClient.new(@user)
      mc.send(method_name, *template_args)
    end

  end


end
