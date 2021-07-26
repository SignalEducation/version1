# frozen_string_literal: true

# All api Exception should be mapped here
module ExceptionHandler
  extend ActiveSupport::Concern
  include Response

  included do
    rescue_from NoMethodError do |e|
      json_response({ error: 'An internal error happened' }, :internal_server_error)
      notify_error(e)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ error: e.message }, :internal_server_error)
      notify_error(e)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ error: e.message }, :not_found)
      notify_error(e)
    end

    private

    def notify_error(e)
      Airbrake.notify(e)
      Appsignal.send_error(e)
    end
  end
end
