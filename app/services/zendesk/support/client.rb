# frozen_string_literal: true

require 'logger'
require 'zendesk_api'

module Zendesk
  module Support
    class Client
      attr_reader :zendesk_api

      def initialize
        credentials  = Rails.application.credentials[Rails.env.to_sym][:zendesk][:api]
        @zendesk_api = build_client(credentials)
      end

      private

      def build_client(credentials)
        ZendeskAPI::Client.new do |config|
          config.url      = credentials[:url]
          config.token    = credentials[:token]
          config.username = credentials[:username]
          config.logger   = Logger.new(Rails.root.join('log', 'zendesk.log'))
        end
      end
    end
  end
end
