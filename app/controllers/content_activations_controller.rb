# frozen_string_literal: true

class ContentActivationsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access content_management_access])
  end
  before_action :set_layout

  def new; end

  def create
    record_type = params[:type].constantize
    @record = record_type.find(params[:id])

    # Defaults to 2AM for the selected date
    @date = DateTime.new(params[:activation_date]['date(1i)'].to_i,
                         params[:activation_date]['date(2i)'].to_i,
                         params[:activation_date]['date(3i)'].to_i,
                         2)

    return unless @record && params[:activation_date]

    ContentActivationWorker.perform_at(@date, record_type, @record.id)
    redirect_to content_activation_special_link(@record)
  end

  protected

  def set_layout
    @layout = 'management'
  end
end
