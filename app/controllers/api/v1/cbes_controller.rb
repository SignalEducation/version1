# frozen_string_literal: true

module Api
  module V1
    class CbesController < Api::V1::ApplicationController
      def index
        @cbes = ::Cbe.all
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
                                    :description,
                                    :exam_time,
                                    :hard_time_limit,
                                    :number_of_pauses_allowed,
                                    :length_of_pauses,
                                    :subject_course_id)
      end
    end
  end
end
