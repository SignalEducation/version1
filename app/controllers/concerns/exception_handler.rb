# frozen_string_literal: true

# All api Exception should be mapped here
module ExceptionHandler
  extend ActiveSupport::Concern
  include Response

  included do
    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ error: e.message }, :internal_server_error)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ error: e.message }, :not_found)
    end
  end
end
