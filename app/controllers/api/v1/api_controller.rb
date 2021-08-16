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
    class ApiController < Api::V1::ApplicationController
      before_action :authenticate

      def logged_in_user
        return if JwtBlockedToken.find_by(token: token_header).present?
        return unless decoded_token

        user_id = decoded_token[0]['user_id']
        @user = User.find_by(id: user_id)
      end

      def logged_in?
        !!logged_in_user
      end

      def authorize_user
        return if logged_in?

        json_response({ message: 'User not logged in. Please log in.' }, :unauthorized)
      end

      private

      def token_header
        request.headers['Token']
      end

      def encode_token(payload)
        secret = Rails.application.credentials[Rails.env.to_sym][:jwt_auth][:secret]

        JWT.encode(payload, secret)
      end

      def decoded_token
        secret = Rails.application.credentials[Rails.env.to_sym][:jwt_auth][:secret]

        JWT.decode(token_header, secret, true, algorithm: 'HS256') if token_header.present?
      end

      def payload(user, days = 14)
        valid_for_days = days * 24 * 60 * 60
        exp            = Time.now.to_i + valid_for_days

        { exp: exp,
          user_name: user.name,
          user_id: user.id }
      end

      def authenticate
        authenticate_or_request_with_http_token do |token, _options|
          @requester = Bearer.active.find_by(api_key: token)
        end
      end
    end
  end
end
