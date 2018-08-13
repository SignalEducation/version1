class ContentActivationsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(system_requirements_access content_management_access))
  end
  before_action :get_variables

  def new
  end

  def create
    record_type = params[:type].constantize
    @record = record_type.find(params[:id])
    if @record && params[:datetime]
      datetime = params[:datetime]
      parsed_time = DateTime.strptime(datetime, '%d/%m/%Y %H:%M:%S')
      ContentActivationWorker.perform_at(parsed_time, record_type, @record.id)

      redirect_to course_module_special_link(@record)
    end
  end


  protected

  def get_variables
    @layout = 'management'
  end


end
