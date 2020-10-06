# frozen_string_literal: true

module Api
  module V1
    class PracticeQuestionsController < Api::V1::ApplicationController
      def index
        @practice_questions = ::CoursePracticeQuestion.all
      end

      def show
        @practice_question = ::CoursePracticeQuestion.find(params[:id])
      end
    end
  end
end
