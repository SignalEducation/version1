# frozen_string_literal: true
# frozen_string_literal: true

# Main class of api, responsible to authenticate api requests.
#
# ==== Examples
# All request should be authenticated by api_key:
#
# Add Token your_api_key_here in Authorization header;
module Api
  module V1
    class ApiController < ApplicationController
      before_action :authenticate

      private

      # TODO: Improve return messages
      # cover invalid api key and inactive users.
      def authenticate
        authenticate_or_request_with_http_token do |token, _options|
          @requester = Bearer.active.find_by(api_key: token)
        end
      end
    end
  end
end
