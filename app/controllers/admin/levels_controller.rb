# frozen_string_literal: true

module Admin
  class LevelsController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :set_variables

    def index
      @levels =
        if params[:group_id]
          Level.where(group_id: params[:group_id]).all_in_order
        else
          Level.all_in_order
        end

      @levels =
        if params[:search].to_s.blank?
          @levels.all_in_order
        else
          @levels.search(params[:search])
        end
    end

    def show; end

    def new
      @level = Level.new(sorting_order: 1)
    end

    def create
      @level = Level.new(allowed_params)

      if @level.save
        flash[:success] = I18n.t('controllers.levels.create.flash.success')
        redirect_to admin_levels_path
      else
        render action: :new
      end
    end

    def edit; end

    def update
      if @level.update(allowed_params)
        flash[:success] = I18n.t('controllers.levels.update.flash.success')
        redirect_to admin_levels_path
      else
        render action: :edit
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |id, counter|
        Level.find_by(id: id).update(sorting_order: (counter + 1))
      end

      render json: {}, status: :ok
    end

    def destroy
      if @level.destroy
        flash[:success] = I18n.t('controllers.levels.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.levels.destroy.flash.error')
      end

      redirect_to admin_levels_url
    end

    protected

    def set_variables
      @level = Level.find_by(id: params[:id]) if params[:id].to_i > 0
      @groups = Group.all_in_order
      @exam_bodies = ExamBody.all_in_order
    end

    def allowed_params
      params.require(:level).permit(
        :name, :name_url, :sorting_order, :active, :track, :group_id, :highlight_colour,
        :sorting_order, :sub_text, :onboarding_course_heading, :onboarding_course_subheading
      )
    end
  end
end
