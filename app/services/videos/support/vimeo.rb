# frozen_string_literal: true

module Videos
  module Support
    class Vimeo
      attr_reader :url, :access_token

      def initialize
        @url          = ENV['LEARNSIGNAL_VIMEO_API_URL']
        @access_token = ENV['LEARNSIGNAL_VIMEO_API_TOKEN']
      end

      def response(params)
        JSON.parse(build_uri(params).read)
      end

      private

      def build_uri(params)
        path = params[:path]
        URI::HTTPS.build(host: url, path: path, query: uri_params(params[:query]))
      end

      def uri_params(query = nil)
        query ||= {}
        { access_token: access_token }.merge(query).to_query
      end
    end
  end
end
