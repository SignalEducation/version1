# frozen_string_literal: true

module Api
  module V1
    class CoursesController < Api::V1::ApplicationController
      def index
        @courses = Course.all_active.all_in_order
        render 'admin/courses/index.json'
      end

      def groups
        @groups = Group.all_active.all_in_order
        @groups = @groups.where(name_url: params[:group_name]) if params[:group_name]

        if @groups.empty?
          render json: { errors: 'Group not found' }, status: :not_found
        else
          render 'api/v1/courses/groups.json'
        end
      end

      def lessons
        group   = Group.find_by(name_url: params[:group_name])
        @course = Course.find_by(name_url: params[:course_name], group: group)

        if group.nil?
          render json: { errors: 'Group not found' }, status: :not_found
        elsif @course.nil?
          render json: { errors: 'Course not found' }, status: :not_found
        else
          render 'api/v1/courses/lessons.json', locals: { course: @course }
        end
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
