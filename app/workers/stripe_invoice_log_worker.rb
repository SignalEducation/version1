# frozen_string_literal: true

class StripeInvoiceLogWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(invoice_id, variable, value)
    SlackService.new.notify_channel('payments',
                                     stripe_failed_notification(invoice_id, variable, value),
                                     icon_emoji: 'rotating_light')
  end

  private

  def stripe_failed_notification(invoice_id, variable, value)
    [{ fallback: "Invoice ##{invoice_id} credit note log.",
       title: "#{variable}: #{value}",
       title_link: "https://dashboard.stripe.com/events/",
       color: '#7CD197',
       footer: 'Stripe' }]
  end
end
