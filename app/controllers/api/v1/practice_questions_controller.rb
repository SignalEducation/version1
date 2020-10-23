# frozen_string_literal: true

module Api
  module V1
    class PracticeQuestionsController < Api::V1::ApplicationController
      before_action :set_practice_question, only: %i[show update]
      before_action :set_course_step_log, only: %i[show update]

      def show; end

      def update
        if update_practice_question_answers(params[:practice_questions])
          render 'api/v1/practice_questions/show.json'
        else
          render json: { errors: @practice_question.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_practice_question
        @practice_question = ::CoursePracticeQuestion.find(params[:id])
      end

      def set_course_step_log
        @course_step_log = CourseStepLog.find(params[:course_step_log_id])
      end

      def update_practice_question_answers(answers)
        @course_step_log.update(element_completed: true) if params[:status] == 'submited'

        answers.each do |answer|
          PracticeQuestion::Answer.find(answer[:answer_id]).update(content: answer[:answer_content])
        end
      end
    end
  end
end
