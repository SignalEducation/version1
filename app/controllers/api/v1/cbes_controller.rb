# frozen_string_literal: true

module Api
  module V1
    class CbesController < Api::V1::ApplicationController
      def index
        @cbes = ::Cbe.all
      end

      def show
        @cbe = ::Cbe.find(params[:id])
        @cbe.to_json
      end

      def update
        @cbe = ::Cbe.find(params[:id])
        @cbe.update(cbe_params)
      end

      def create
        @cbe = ::Cbe.new(cbe_params)

        if @cbe.save
          render 'api/v1/cbes/show.json'
        else
          render json: { errors: @cbe.errors }, status: :unprocessable_entity
        end
      end

      private

      def cbe_params
        params.require(:cbe).permit(:name,
                                    :title,
                                    :content,
                                    :exam_time,
                                    :agreement_content,
                                    :active,
                                    :subject_course_id)
      end
    end
  end
end
