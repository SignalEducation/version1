# frozen_string_literal: true

module Admin
  class ExhibitsController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :set_variables

    def index
      @course_step_id = params[:course_step_id]
      @exhibits = PracticeQuestion::Exhibit.where(practice_question_id: @practice_question.id).all_in_order

      render 'admin/course_practice_questions/exhibits/index'
    end

    def new
      last_exhibit = @practice_question&.exhibits&.all_in_order&.last&.sorting_order
      @exhibit = PracticeQuestion::Exhibit.new(sorting_order: last_exhibit + 1 || 1, practice_question_id: params[:id])
      render 'admin/course_practice_questions/exhibits/new'
    end

    def create
      @practice_question = CoursePracticeQuestion.find(params[:practice_question_exhibit][:practice_question_id])
      @exhibit = PracticeQuestion::Exhibit.new(allowed_params)

      if @exhibit.save
        flash[:success] = 'Exhibit succesfully created'
      else
        flash[:error] = 'Exhibit not created'
      end

      redirect_to admin_course_step_practice_question_exhibits_url(course_step_id: @practice_question.course_step_id, practice_question_id: @practice_question.id)
    end

    def edit
      @exhibit = PracticeQuestion::Exhibit.find(params[:id])

      render 'admin/course_practice_questions/exhibits/edit'
    end

    def update
      @practice_question = CoursePracticeQuestion.find(params[:practice_question_exhibit][:practice_question_id])
      @exhibit = PracticeQuestion::Exhibit.where(id: params[:practice_question_exhibit][:id]).first
      if @exhibit.update_attributes(allowed_params)
        flash[:success] = 'Exhibit succesfully updated'
        redirect_to admin_course_step_practice_question_exhibits_url(course_step_id: @exhibit.practice_question.course_step_id, practice_question_id: @exhibit.practice_question.id)
      else
        flash[:error] = 'Exhibit not succesfully updated'
        render 'admin/course_practice_questions/exhibits/edit'
      end
    end

    def destroy
      @exhibit = PracticeQuestion::Exhibit.find(params[:id])

      if @exhibit
        @exhibit.destroy
        flash[:success] = 'Exhibit succesfully deleted'
      else
        flash[:error] = 'Exhibit not succesfully deleted'
      end

      redirect_to admin_course_step_practice_question_exhibits_url(course_step_id: @practice_question.course_step_id, practice_question_id: @practice_question.id)
    end

    protected

    def set_variables
      @course_step = CourseStep.where(id: params[:id]).first if params[:id].to_i.positive?
      @practice_question = CoursePracticeQuestion.find(params[:practice_question_id])
    end

    def allowed_params
      params.require(:practice_question_exhibit).permit(
        :id,
        :name,
        :sorting_order,
        :kind,
        :content,
        :document,
        :practice_question_id
      )
    end
  end
end
