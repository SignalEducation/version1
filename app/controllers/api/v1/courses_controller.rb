# frozen_string_literal: true

module Api
  module V1
    class CoursesController < Api::V1::ApplicationController
      def index
        @courses = Course.all_active.all_in_order
        render 'admin/courses/index.json'
      end

      def read_note_log
        step_log = CourseStepLog.find(params[:step_log_id])

        if step_log.update(element_completed: true)
          render json: { element_completed: step_log.element_completed }, status: :ok
        else
          render json: { errors: step_log.errors.messages }, status: :error
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Invalid step log' }, status: :error
      end
    end
  end
end
