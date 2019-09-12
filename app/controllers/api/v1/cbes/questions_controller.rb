# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class QuestionsController < Api::V1::ApplicationController
        def index
          @questions = ::Cbe::Question.all
        end

        def create
          @question = ::Cbe::Question.new(permitted_params)

          unless @question.save
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
