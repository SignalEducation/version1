# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :logged_in_required
  before_action :get_variables

  def show
    @default_group = current_user&.preferred_exam_body&.group || Group.all_active.all_active.first
    @enrollments = current_user.valid_enrollments_in_sitting_order
    @sculs = current_user.course_logs.includes(:enrollments).where(enrollments: { id: nil })
  end

  protected

  def get_variables
    @courses = Course.all_active.all_in_order
    seo_title_maker('Dashboard', 'Progress through all your courses will be recorded here.', false)
  end
end
