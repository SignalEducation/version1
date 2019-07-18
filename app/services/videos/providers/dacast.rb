# frozen_string_literal: true

module Videos
  module Providers
    class Dacast < Support::Dacast
      include ActionView::Helpers::TextHelper

      def list
        query = { method: 'get' }
        start_service('vod', query)
      end

      def upload(link)
        query = { method: 'post',
                  source: link,
                  upload_type: 'http_external',
                  callback_url: "#{ENV['DACAST_CALLBACK_URL']}/api/dacast_response" }
        start_service('vod', query)
      end

      def delete(id)
        query = { method: 'delete' }
        start_service("vod/#{id}", query)
      end

      def update(id, data)
        query = { method: 'put',
                  title: truncate(data['name'], length: 50),
                  description: data['description'],
                  online: true,
                  publish_on_dacast: false }

        start_service("vod/#{id}", query)
      end

      private

      def start_service(specified_path, query)
        response(path: specified_path, query: query)
      end
    end
  end
end
