# frozen_string_literal: true

module Api
  module V1
    class SubjectCoursesController < Api::V1::ApplicationController
      def index
        @courses = Course.all_active.all_in_order
        render 'courses/index.json'
      end
    end
  end
end
