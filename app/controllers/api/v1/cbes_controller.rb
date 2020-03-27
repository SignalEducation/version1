# frozen_string_literal: true

module Api
  module V1
    class CbesController < Api::V1::ApplicationController
      before_action :set_cbe, only: %i[show update edit]
      def index
        @cbes = ::Cbe.all
      end

      def show; end

      def edit; end

      def create
        @cbe = ::Cbe.new(cbe_params)

        if @cbe.save
          render 'api/v1/cbes/show.json'
        else
          render json: { errors: @cbe.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @cbe.update(cbe_params)
          render 'api/v1/cbes/show.json'
        else
          render json: { errors: @cbe.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_cbe
        @cbe = ::Cbe.find(params[:id])
      end

      def cbe_params
        params.require(:cbe).permit(:name,
                                    :title,
                                    :content,
                                    :exam_time,
                                    :agreement_content,
                                    :active,
                                    :course_id)
      end
    end
  end
end
