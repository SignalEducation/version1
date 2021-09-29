# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :logged_in_required
  before_action :get_variables

  def show
    @default_group       = current_user&.preferred_exam_body&.group || Group.all_active.first
    @levels              = @default_group&.levels&.all_active&.all_in_order
    @enrollments         = current_user.valid_enrollments_in_sitting_order
    @sculs               = current_user.course_logs.includes(:enrollments).where(enrollments: { id: nil })
    @cancelled_orders_id = filter_cancelled_orders(current_user&.orders)
  end

  protected

  def get_variables
    @courses = Course.all_active.all_in_order
    seo_title_maker('Dashboard | LearnSignal', 'Progress through all your courses will be recorded here.', false)
  end

  def filter_cancelled_orders(user_orders)
    (user_orders.map { |order| order.state == 'cancelled' ? order.id : nil }).compact
  end
end
