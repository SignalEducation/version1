# frozen_string_literal: true
module Admin
  class TutorDetailsController < ApplicationController
    before_action :logged_in_required
    before_action do
      ensure_user_has_access_rights(%w[system_requirements_access content_management_access user_management_access])
    end
    before_action :management_layout
    before_action :get_variables

    def index
      @tutor_details = @course.tutor_details.all_in_order
    end

    def new
      @tutor_detail = TutorDetail.new(course_id: @course.id, sorting_order: 1)
    end

    def edit; end

    def create
      @tutor_detail = TutorDetail.new(allowed_params)

      if @tutor_detail.save
        flash[:success] = I18n.t('controllers.tutor_details.create.flash.success')
        redirect_to tutor_details_url(@course)
      else
        render action: :new
      end
    end

    def update
      if @tutor_detail.update_attributes(allowed_params)
        flash[:success] = I18n.t('controllers.tutor_details.update.flash.success')
        redirect_to tutor_details_url(@course)
      else
        render action: :edit
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |the_id, counter|
        TutorDetail.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
      end

      render json: {}, status: :ok
    end

    def destroy
      if @tutor_detail.destroy
        flash[:success] = I18n.t('controllers.tutor_details.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.tutor_details.destroy.flash.error')
      end

      redirect_to tutor_details_url(@course)
    end

    protected

    def get_variables
      @tutor_detail = TutorDetail.where(id: params[:id]).first if params[:id].to_i > 0
      @course       = Course.where(id: params[:course_id]).first if params[:course_id].to_i > 0
      @tutor_users  = User.all_tutors.all_in_order
    end

    def allowed_params
      params.require(:tutor_detail).permit(:course_id, :user_id, :sorting_order, :title)
    end
  end
end
