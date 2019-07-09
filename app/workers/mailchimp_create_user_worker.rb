class MailchimpCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id, subscribe)
    MailchimpService.new.add_subscriber(user_id, subscribe)
  end

end
