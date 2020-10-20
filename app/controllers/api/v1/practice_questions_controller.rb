# frozen_string_literal: true

module Api
  module V1
    class PracticeQuestionsController < Api::V1::ApplicationController
      before_action :set_practice_question, only: %i[show update]
      # before_action :update_step_log, only: :update

      def index
        @practice_questions = ::CoursePracticeQuestion.all
      end

      def show; end

      def update
        render json: { ok: 'For now' }, status: :ok
        # binding.pry
        # if @practice_question.update(practice_question_params)
        #   update_step_log(@practice_question.answers.last)
        #   render 'api/v1/practice_questions/show.json'
        # else
        #   render json: { errors: @practice_question.errors }, status: :unprocessable_entity
        # end
      end

      def update_step_log(answer)
        @course_step_log = CourseStepLog.find(params[:step_log])
        @course_step_log.update(current_practice_question_answer_id: answer.id)
      end

      private

      def set_practice_question
        @practice_question = ::CoursePracticeQuestion.find(params[:id])
      end

      def set_course_step_log
        @course_step_log = CourseStepLog.find(params[:step_log])
      end

      def practice_question_params
        params.require(:practice_question).permit(:course_step_id,
                                                  :id,
                                                  answers_attributes: [
                                                    :id,
                                                    :kind,
                                                    :practice_question_question_id,
                                                    :content,
                                                    :solution,
                                                  ])
      end
    end
  end
end
