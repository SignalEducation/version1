# frozen_string_literal: true

# All api Exception should be mapped here
module ExceptionHandler
  extend ActiveSupport::Concern
  include Response

  included do
    rescue_from NoMethodError do |e|
      notify_error(e, e.message, :internal_server_error)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      notify_error(e, e.message, :internal_server_error)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      notify_error(e, e.message, :not_found)
    end

    rescue_from ActiveRecord::RecordNotUnique do |e|
      notify_error(e, format_not_unique_message(e), :not_acceptable)
    end

    rescue_from JWT::DecodeError do |e|
      notify_error(e, e.message, :internal_server_error)
    end

    private

    def notify_error(e, error, status)
      Airbrake.notify(e)
      Appsignal.send_error(e)

      json_response({ errors: error }, status)
    end

    def format_not_unique_message(error)
      error_key     = error.message.match(/Key.*$/)[0].match(/(?<=\().+?(?=\))/)[0]
      error_message = error.message.match(/Key.*$/)[0].match(/[^\)]+$/)[0]

      { error_key => [error_message] }
    end
  end
end
