# frozen_string_literal: true

# A json response helper
module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
