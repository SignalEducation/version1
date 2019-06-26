class MailchimpCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(list_id, user_id, subscribe)
    MailchimpService.new.add_subscriber(list_id, user_id, subscribe)
  end

end
