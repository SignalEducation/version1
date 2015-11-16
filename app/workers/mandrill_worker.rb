class MandrillWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'high'

  def perform(user_id, request_id, method_name, *template_args)
    @user = User.find_by_id(user_id)
    @request = WhitePaperRequest.find_by_id(request_id)
    if @user && @user.email
      mc = MandrillClient.new(@user, nil)
      mc.send(method_name, *template_args)
    elsif @request && @request.email
      mc = MandrillClient.new(nil, @request)
      mc.send(method_name, *template_args)
    end
  end
end
