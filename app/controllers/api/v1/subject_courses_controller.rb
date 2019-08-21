# frozen_string_literal: true

module Api
  module V1
    class SubjectCoursesController < Api::V1::ApplicationController
      def index
        @subject_courses = SubjectCourse.all
        render 'subject_courses/index.json'
      end
    end
  end
end
