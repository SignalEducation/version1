class MailchimpCreateUserWorker

  include Sidekiq::Worker

  def perform(list_id, user_id, subscribe = true)
    mailchimp.add_subscriber(list_id, user_id, subscribe)
  rescue StandardError => e
    raise e
  end

  private

  def mailchimp
    @mailchimp = MailchimpService.new
  end

end