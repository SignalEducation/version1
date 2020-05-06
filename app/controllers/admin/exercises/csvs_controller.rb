# frozen_string_literal: true

module Admin
  module Exercises
    class CsvsController < ApplicationController
      before_action :logged_in_required
      before_action { ensure_user_has_access_rights(%w[user_management_access]) }
      before_action :management_layout

      def preview
        if params.dig(:upload, :file)&.respond_to?(:read)
          @users, @has_errors = Exercise.parse_csv(params[:upload][:file].read)
        else
          flash[:error] = t('controllers.dashboard.preview_csv.flash.error')
          redirect_to admin_exercises_url
        end
      end

      def upload
        if valid_params?(params)
          @exercises = Exercise.bulk_create(upload_params[:csvdata], upload_params[:product_id])
          flash[:success] = t('controllers.dashboard.import_csv.flash.success')
        else
          flash[:error] = t('controllers.dashboard.preview_csv.flash.error')
          redirect_to admin_exercises_url
        end
      end

      private

      def upload_params
        params.require(:upload).permit(:product_id, csvdata: {})
      end

      def valid_params?(params)
        params.dig(:upload, :csvdata) && params.dig(:upload, :product_id)
      end
    end
  end
end
