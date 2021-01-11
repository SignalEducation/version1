# frozen_string_literal: true

module Admin
  class SolutionsController < ApplicationController
    include PracticeQuestions
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :set_variables

    def index
      @course_step_id = params[:course_step_id]
      @solutions = PracticeQuestion::Solution.where(practice_question_id: @practice_question.id).all_in_order

      render 'admin/course_practice_questions/solutions/index'
    end

    def new
      @solution = new_practice_question_resource(@practice_question&.solutions&.all_in_order&.last&.sorting_order, 'solution', params[:id])

      render 'admin/course_practice_questions/solutions/new'
    end

    def create
      @practice_question = CoursePracticeQuestion.find(params[:practice_question_solution][:practice_question_id])
      @solution = PracticeQuestion::Solution.new(allowed_params)

      if @solution.save
        flash[:success] = 'Solution successfully created'
      else
        flash[:error] = 'Solution not created'
      end

      redirect_to admin_course_step_practice_question_solutions_url(course_step_id: @practice_question.course_step_id, practice_question_id: @practice_question.id)
    end

    def edit
      @solution = PracticeQuestion::Solution.find(params[:id])

      render 'admin/course_practice_questions/solutions/edit'
    end

    def update
      @practice_question = CoursePracticeQuestion.find(params[:practice_question_solution][:practice_question_id])
      @solution = PracticeQuestion::Solution.where(id: params[:practice_question_solution][:id]).first
      if @solution.update_attributes(allowed_params)
        flash[:success] = 'Solution succesfully updated'
        redirect_to admin_course_step_practice_question_solutions_url(course_step_id: @solution.practice_question.course_step_id, practice_question_id: @solution.practice_question.id)
      else
        flash[:error] = 'Solution not succesfully updated'
        render 'admin/course_practice_questions/solutions/edit'
      end
    end

    def destroy
      @solution = PracticeQuestion::Solution.find(params[:id])

      if @solution
        @solution.destroy
        flash[:success] = 'Solution succesfully deleted'
      else
        flash[:error] = 'Solution not succesfully deleted'
      end

      redirect_to admin_course_step_practice_question_solutions_url(course_step_id: @practice_question.course_step_id, practice_question_id: @practice_question.id)
    end

    protected

    def set_variables
      @course_step = CourseStep.where(id: params[:id]).first if params[:id].to_i.positive?
      @practice_question = CoursePracticeQuestion.find(params[:practice_question_id])
    end

    def allowed_params
      params.require(:practice_question_solution).permit(
        :id,
        :name,
        :sorting_order,
        :kind,
        :content,
        :practice_question_id
      )
    end
  end
end
