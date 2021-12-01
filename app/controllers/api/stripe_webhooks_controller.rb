# frozen_string_literal: true

module Api
  class StripeWebhooksController < Api::BaseController
    protect_from_forgery except: :create
    before_action :process_json, only: :create

    def create
      record_webhook(@event_json) if @event_json && StripeApiEvent.should_process?(@event_json)

      head :no_content
    rescue StandardError => e
      slack = SlackService.new

      slack.notify_channel('payments', webhook_failed_notification(e, @event_json), icon_emoji: 'rotating_light') if Rails.env.production?
      Rails.logger.error('ERROR: Api/StripeWebhooks#Create: Error: ' \
                         "#{e.inspect}\nEvent: #{@event_json['id']}")
      head :not_found
    end

    private

    def process_json
      @event_json = JSON.parse(request.body.read) if request.body.present?
    end

    def record_webhook(event_json)
      StripeApiProcessorWorker.perform_at(
        StripeApiEvent.processing_delay(event_json['type']),
        event_json['id'], event_json['api_version'], account_url
      )
    end

    def webhook_failed_notification(error, event_json)
      [{ fallback: "Stripe webhook ##{event_json['id']} have failed.",
         title: "Stripe webhook ##{event_json['id']} have failed.\nError: #{error.inspect}",
         title_link: "https://dashboard.stripe.com/events/#{event_json['id']}",
         color: '#7CD197',
         footer: 'Stripe',
         ts: event_json['created'] }]
    end
  end
end
