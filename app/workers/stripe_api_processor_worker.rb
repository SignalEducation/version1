# frozen_string_literal: true

class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version, account_url = '')
    StripeApiEvent.create!(guid: stripe_event_id, api_version: api_version,
                           account_url: account_url)
  rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid => e
    Rails.logger.error "StripeApiEvent#existing_guid #{e.inspect}"
    if Rails.env.production?
      SlackService.new.notify_channel('payments',
                                      webhook_failed_notification(e, stripe_event_id),
                                      icon_emoji: 'rotating_light')
    end
  end

  private

  def stripe_failed_notification(error, stripe_event_id)
    [{ fallback: "Stripe webhook ##{stripe_event_id} have failed.",
       title: "Stripe webhook ##{stripe_event_id} have failed.\nError: #{error.inspect}",
       title_link: "https://dashboard.stripe.com/events/#{stripe_event_id}",
       color: '#7CD197',
       footer: 'Stripe' }]
  end
end
