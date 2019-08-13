# frozen_string_literal: true

module Api
  class StripeWebhooksController < Api::BaseController
    protect_from_forgery except: :create
    before_action :process_json, only: :create

    def create
      if @event_json && StripeApiEvent.should_process?(@event_json)
        record_webhook(@event_json)
      end
      head :no_content
    rescue StandardError => e
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
  end
end
