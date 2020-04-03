# frozen_string_literal: true

module Admin
  class CourseNotesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :get_variables

    def index
      @course_notes = @course_step.course_notes
    end

    def new
      @action = :create
      @course_note = CourseNote.new(course_step_id: params[:course_step_id].to_i)
    end

    def create
      @course_note = CourseNote.new(allowed_params)

      if @course_note.save
        flash[:success] = I18n.t('controllers.course_notes.create.flash.success')
        redirect_to edit_admin_course_step_url(@course_step.id)

      else
        render action: :new
      end
    end

    def edit
      @action = :update
    end

    def update
      if @course_note.update_attributes(allowed_params)
        flash[:success] = I18n.t('controllers.course_notes.update.flash.success')
        redirect_to edit_admin_course_step_url(@course_step.id)
      else
        render action: :edit
      end
    end

    def destroy
      if @course_note.destroy
        flash[:success] = I18n.t('controllers.course_notes.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.course_notes.destroy.flash.error')
      end
      redirect_to edit_admin_course_step_url(@course_step.id)
    end

    protected

    def get_variables
      @course_step = CourseStep.where(id: params[:course_step_id]).first
      @course_note = CourseNote.where(id: params[:id]).first if params[:id].to_i > 0
      @mathjax_required = true
    end

    def allowed_params
      params.require(:course_note).permit(:course_step_id, :name, :description,
                                                    :web_url, :upload, :upload_file_name, :upload_content_type,
                                                    :upload_file_size, :upload_updated_at, :_destroy)
    end
  end
end
