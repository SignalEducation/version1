# frozen_string_literal: true

module Api
  module V1
    module Cbe
      class QuestionsController < Api::V1::ApplicationController
        def index
          @questions = ::Cbe::Question.all
        end

        def create

          @question = ::Cbe::Question.new(permitted_params)

          if @question.save
            render 'api/v1/cbe/questions/show.json'
          else
            render json: { errors: @question.errors }, status: :unprocessable_entity
          end
        end

        private

        def permitted_params
          params.require(:question).permit(
            :kind,
            :content,
            :score,
            :cbe_scenario_id,
            :cbe_section_id
          )
        end
      end
    end
  end
end
