# frozen_string_literal: true

class CourseModuleElementResourcesController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[content_management_access]) }
  before_action :management_layout
  before_action :get_variables

  def index
    @course_module_element_resources = @course_module_element.course_module_element_resources
  end

  def new
    @course_module_element_resource = CourseModuleElementResource.new(course_module_element_id: params[:course_module_element_id].to_i)
  end

  def create
    @course_module_element_resource = CourseModuleElementResource.new(allowed_params)

    if @course_module_element_resource.save
      flash[:success] = I18n.t('controllers.course_module_element_resources.create.flash.success')
      redirect_to edit_course_module_element_url(@course_module_element.id)

    else
      render action: :new
    end
  end

  def edit; end

  def update
    if @course_module_element_resource.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_module_element_resources.update.flash.success')
      redirect_to edit_course_module_element_url(@course_module_element.id)
    else
      render action: :edit
    end
  end

  def destroy
    if @course_module_element_resource.destroy
      flash[:success] = I18n.t('controllers.course_module_element_resources.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_module_element_resources.destroy.flash.error')
    end
    redirect_to edit_course_module_element_url(@course_module_element.id)
  end

  protected

  def get_variables
    @course_module_element = CourseModuleElement.where(id: params[:course_module_element_id]).first
    @course_module_element_resource = CourseModuleElementResource.where(id: params[:id]).first if params[:id].to_i > 0
    @mathjax_required = true
  end

  def allowed_params
    params.require(:course_module_element_resource).permit(:course_module_element_id, :name, :description,
                                                  :web_url, :upload, :upload_file_name, :upload_content_type,
                                                  :upload_file_size, :upload_updated_at, :_destroy)
  end
end