class MandrillWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekia_options queue: 'low'

  def perform(user_id, template_name, *template_args)
    @user = User.find_by_id(user_id)
    if @user && @user.email
      mc = MandrillClient.new(@user)
      mc.call(template_name, template_args)
    end
  end
end
