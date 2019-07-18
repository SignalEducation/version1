# frozen_string_literal: true

module Videos
  module Providers
    class Vimeo < Support::Vimeo
      def list
        start_service('/me/videos')
      end

      def data(id)
        start_service("/me/videos/#{id}")
      end

      private

      def start_service(specified_path)
        response(path: specified_path)
      end
    end
  end
end
