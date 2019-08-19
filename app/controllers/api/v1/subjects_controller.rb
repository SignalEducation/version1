# frozen_string_literal: true

module Api
  module V1
    class SubjectsController < Api::V1::ApplicationController
      def index
        render json: SubjectCourse.select([:id, :name])
      end
    end
  end
end