# frozen_string_literal: true

module Admin
  class KeyAreasController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :set_variables

    def index
      @key_areas =
        if params[:group_id]
          KeyArea.where(group_id: params[:group_id]).all_in_order
        else
          KeyArea.all_in_order
        end

      @key_areas =
        if params[:search].to_s.blank?
          @key_areas.all_in_order
        else
          @key_areas.search(params[:search])
        end
    end

    def show; end

    def new
      @key_area = KeyArea.new(sorting_order: 1)
      @levels = []
    end

    def create
      @key_area = KeyArea.new(allowed_params)

      if @key_area.save
        flash[:success] = I18n.t('controllers.key_areas.create.flash.success')
        redirect_to admin_key_areas_path
      else
        render action: :new
      end
    end

    def edit
      @levels = @key_area.group.levels
    end

    def update
      if @key_area.update(allowed_params)
        flash[:success] = I18n.t('controllers.key_areas.update.flash.success')
        redirect_to admin_key_areas_path
      else
        render action: :edit
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |id, counter|
        KeyArea.find_by(id: id).update(sorting_order: (counter + 1))
      end

      render json: {}, status: :ok
    end

    def destroy
      if @key_area.destroy
        flash[:success] = I18n.t('controllers.key_areas.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.key_areas.destroy.flash.error')
      end

      redirect_to admin_key_areas_url
    end

    protected

    def set_variables
      @key_area = KeyArea.find_by(id: params[:id]) if params[:id].to_i > 0
      @groups = Group.all_in_order
      @exam_bodies = ExamBody.all_in_order
    end

    def allowed_params
      params.require(:key_area).permit(:name, :sorting_order, :active, :group_id, :level_id)
    end
  end
end
