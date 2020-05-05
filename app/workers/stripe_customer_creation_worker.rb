# frozen_string_literal: true

class StripeCustomerCreationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    user = User.find(user_id)
    StripeService.new.create_customer!(user)
  end
end
