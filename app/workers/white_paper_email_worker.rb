class WhitePaperEmailWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'high'

  def perform(name, email, method_name, *template_args)
    @user = User.new(first_name: name, last_name: '', email: email)
    @corporate = nil
    if @user && @user.email
      mc = MandrillClient.new(@user, @corporate)
      mc.send(method_name, *template_args)
    end

  end

end
