# frozen_string_literal: true

# All api Exception should be mapped here
module ExceptionHandler
  extend ActiveSupport::Concern
  include Response

  included do
    rescue_from NoMethodError do |e|
      notify_error(e, :internal_server_error)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      notify_error(e, :internal_server_error)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      notify_error(e, :not_found)
    end

    rescue_from JWT::DecodeError do |e|
      notify_error(e, :internal_server_error)
    end

    private

    def notify_error(e, status)
      Airbrake.notify(e)
      Appsignal.send_error(e)

      json_response({ error: e.message }, status)
    end
  end
end
