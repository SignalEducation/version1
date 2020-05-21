# frozen_string_literal: true

module Accredible
  module Support
    # Responsible to manage all Accredible api requests.
    class Connection
      attr_reader :credentials

      def initialize
        @credentials = Rails.application.credentials[Rails.env.to_sym][:accredible]
      end

      def response(params)
        method       = params[:method]
        body         = params[:query].to_json
        uri          = build_uri(params[:path])
        http         = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        headers      = { 'Content-Type': 'application/json',
                         'Authorization': "Token token=#{credentials[:api_key]}" }

        case method
        when :get
          http.get(uri.request_uri, headers)
        when :post
          http.post(uri.request_uri, body, headers)
        end
      end

      private

      def build_uri(path)
        URI.parse("https://#{credentials[:api_url]}/v1/#{path}")
      end
    end
  end
end
