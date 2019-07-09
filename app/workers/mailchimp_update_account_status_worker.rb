class MailchimpUpdateAccountStatusWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id)
    MailchimpService.new.update_account_status(user_id)
  end

end
