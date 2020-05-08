# frozen_string_literal: true

module Admin
  class CourseResourcesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :get_variables

    def index
      @course_resources = CourseResource.paginate(per_page: 50, page: params[:page]).all_in_order
    end

    def show; end

    def new
      @action = :create
      @course_resource = CourseResource.new
    end

    def edit
      @action = :update
    end

    def create
      @course_resource = CourseResource.new(allowed_params)

      if @course_resource.save
        flash[:success] = I18n.t('controllers.course_resources.create.flash.success')
        redirect_to admin_course_resources_url(@course_resource.course)
      else
        render action: :new
      end
    end

    def update
      if @course_resource.update_attributes(allowed_params)
        flash[:success] = I18n.t('controllers.course_resources.update.flash.success')
        redirect_to admin_course_resources_url(@course_resource.course)
      else
        render action: :edit
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |the_id, counter|
        CourseResource.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
      end
      render json: {}, status: :ok
    end

    def destroy
      if @course_resource.destroy
        flash[:success] = I18n.t('controllers.course_resources.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.course_resources.destroy.flash.error')
      end

      redirect_to admin_course_resources_url
    end

    protected

    def get_variables
      @course_resource = CourseResource.find_by(id: params[:id]) if params[:id].to_i > 0
      @courses = Course.all_in_order
    end

    def allowed_params
      params.require(:course_resource).permit(
        :name, :course_id, :description, :download_available,
        :file_upload, :external_url, :active, :sorting_order, :available_on_trial
      )
    end
  end
end
