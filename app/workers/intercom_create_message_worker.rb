class IntercomCreateMessageWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, email, full_name, message, type)
    IntercomNewMessageService.new({user_id: user_id, email: email, full_name: full_name, message: message, type: type}).perform
  end

end
