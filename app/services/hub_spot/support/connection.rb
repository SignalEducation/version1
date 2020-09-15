# frozen_string_literal: true

module HubSpot
  module Support
    # Responsible to manage all HubSpot api requests.
    class Connection
      attr_reader :credentials, :api_kind

      def initialize(api)
        @api_kind = api
        @credentials = Rails.application.credentials[Rails.env.to_sym][:hubspot][api_kind]
      end

      def response(params)
        body         = params[:body].to_json
        method       = params[:method]
        uri          = build_uri(params[:path], params[:query])
        headers      = { 'Content-Type': 'application/json' }
        http         = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        case method
        when 'get'
          http.get(uri.request_uri, headers)
        when 'post'
          http.post(uri.request_uri, body, headers)
        end
      end

      private

      def build_uri(path, query = nil)
        URI::HTTPS.build(host: credentials[:url],
                         path: path,
                         query: query&.to_query)
      end
    end
  end
end
