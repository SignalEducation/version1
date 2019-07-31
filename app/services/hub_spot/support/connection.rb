# frozen_string_literal: true

module HubSpot
  module Support
    # Responsible to manage all HubSpot api requests.
    class Connection
      attr_reader :credentials

      def initialize
        @credentials = Rails.application.credentials[Rails.env.to_sym][:hubspot]
      end

      def response(params)
        body     = params[:query].to_json
        method   = params[:method]
        uri      = build_uri(params[:path])
        headers  = { 'Content-Type': 'application/json' }
        http     = Net::HTTP.new(uri.host)

        http.send(method, uri.request_uri, body, headers)
      end

      private

      def build_uri(path)
        URI::HTTP.build(host: credentials[:url],
                        path: path,
                        query: { hapikey: credentials[:api_key] }.to_query)
      end
    end
  end
end
