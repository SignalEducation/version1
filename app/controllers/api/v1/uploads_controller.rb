# frozen_string_literal: true

module Api
  module V1
    class UploadsController < Api::V1::ApplicationController
      def create
        @s3_upload_url_service = UploadUrlService.new(upload_params[:filename])
        @s3_upload_url_service.call
        render json: {
          upload: {
            url: @s3_upload_url_service.url,
            content_type: @s3_upload_url_service.content_type
          }
        }, status: :created
      end

      private

      def upload_params
        params.require(:upload).permit(:filename)
      end
    end
  end
end
