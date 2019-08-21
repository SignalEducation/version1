# frozen_string_literal: true

module Api
  module V1
    class CbeMultipleChoiceQuestionsController < Api::V1::ApplicationController
      def create
        cbeMultipleChoiceQuestion = CbeMultipleChoiceQuestion.create(permitted_params)
        res = { cbeMultipleChoiceQuestionId: cbeMultipleChoiceQuestion.id }
        render json: res.as_json
      end

      def index
        questions = CbeMultipleChoiceQuestion.all.
                      to_json(only: %i[id
                                       cbe_section_id
                                       question_1
                                       question_2
                                       question_3
                                       question_4
                                       correct_answer])
        render json: questions
      end

      private

      def permitted_params
        params.require(:cbe_multiple_choice_question).
          permit(
            :cbe_section_id,
            :name,
            :description,
            :question_1,
            :question_2,
            :question_3,
            :question_4,
            :correct_answer
          )
      end
    end
  end
end
