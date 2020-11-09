# frozen_string_literal: true

class PaypalCronWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform
    Paypal::SubscriptionValidation.run_paypal_sync
  end
end
