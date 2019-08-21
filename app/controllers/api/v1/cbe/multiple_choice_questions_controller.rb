# frozen_string_literal: true

module Api
  module V1
    module Cbe
      class MultipleChoiceQuestionsController < Api::V1::ApplicationController
        def index
          @multiple_choice_questions = ::Cbe::MultipleChoiceQuestion.all
        end

        def create
          @multiple_choice_question = ::Cbe::MultipleChoiceQuestion.new(permitted_params)

          if @multiple_choice_question.save
            render 'api/v1/cbe/multiple_choice_questions/show.json'
          else
            render json: { errors: @multiple_choice_question.errors }, status: :unprocessable_entity
          end
        end

        private

        def permitted_params
          params.require(:cbe_multiple_choice_question).permit(
            :label,
            :order,
            :name,
            :description,
            :question_1,
            :question_2,
            :question_3,
            :question_4,
            :correct_answer,
            :cbe_section_id
          )
        end
      end
    end
  end
end
