# frozen_string_literal: true

module Api
  module V1
    class ExamBodiesController < Api::V1::ApiController
      def index
        @exam_bodies = ExamBody.all_active.all_in_order

        render 'api/v1/exam_bodies/index.json'
      end
    end
  end
end
