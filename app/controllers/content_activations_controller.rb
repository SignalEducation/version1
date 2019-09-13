# frozen_string_literal: true

class ContentActivationsController < ApplicationController
  before_action :logged_in_required
  before_action :management_layout
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access content_management_access])
  end

  def new; end

  def create
    date   = params[:activation_date].to_datetime
    record = find_record(params[:type], params[:id])

    return if record.nil?

    ContentActivationWorker.perform_at(date, record.class, record.id)

    redirect_to content_activation_special_link(record)
  end

  private

  def find_record(type, id)
    type.constantize.find_by(id: id)
  end
end
