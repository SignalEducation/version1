# frozen_string_literal: true

module Videos
  module Support
    class Dacast
      require 'net/http'
      attr_reader :url, :key

      def initialize
        @url = ENV['DACAST_API_URL']
        @key = ENV['DACAST_API_KEY']
      end

      def response(params)
        JSON.parse(connect(params))
      end

      private

      def build_uri(path)
        URI::HTTP.build(host: url,
                        path: "/v2/#{path}",
                        query: { apikey: key }.to_query,
                        port: 443)
      end

      def connect(params)
        uri      = build_uri(params[:path])
        body     = params[:query].to_json
        headers  = { 'Content-Type': 'application/json' }
        http     = Net::HTTP.new(uri.host)

        case params[:query][:method]
        when 'post'
          http.post(uri.request_uri, body, headers).body
        when 'put'
          http.put(uri.request_uri, body, headers).body
        when 'get'
          http.get(uri.request_uri, body, headers).body
        when 'delete'
          http.delete(uri.request_uri).body
        end
      end
    end
  end
end
