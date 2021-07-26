# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::Base
      include ExceptionHandler
      include Response

      protect_from_forgery unless: -> { request.format.json? }
    end
  end
end
