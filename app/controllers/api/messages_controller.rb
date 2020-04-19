# frozen_string_literal: true

module Api
  class MessagesController < Api::BaseController
    protect_from_forgery except: :update

    def update
      JSON.parse(params['mandrill_events']).each do |raw_event|
        Message.process_webhook_event(raw_event)
      end

      render body: nil, status: :no_content
    rescue StandardError => e
      Rails.logger.error('ERROR: Api/Messages#Update: Error: ' "#{e.inspect}\n")
      head :not_found
    end
  end
end
