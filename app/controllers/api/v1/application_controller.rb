# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      include ActionController::Cookies
      include ActionController::HttpAuthentication::Basic::ControllerMethods
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include ExceptionHandler
      include Response

      def current_user
        @current_user ||= current_user_session&.record
      end

      def current_user_session
        @current_user_session ||= UserSession.find
      end
    end
  end
end
