class MailchimpAddCheckoutTagWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id, type, state)
    MailchimpService.new.audience_checkout_tag(user_id, type, state)
  end

end
