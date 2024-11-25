# frozen_string_literal: true

class QuizQuestionsController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[content_management_access]) }
  before_action :management_layout, except: :reorder
  before_action :get_variables, except: :reorder

  def show; end

  def new
    @quiz_question.quiz_contents.build
    @quiz_question.quiz_solutions.build
    @quiz_question.course_quiz.course_step.course_lesson.course.default_number_of_possible_exam_answers.times do
      @quiz_question.quiz_answers.build
      @quiz_question.quiz_answers.last.quiz_contents.build
    end
  end

  def edit
    @quiz_question = QuizQuestion.find(params[:id])
  end

  def create
    if @quiz_question.save
      flash[:success] = I18n.t('controllers.quiz_questions.create.flash.success')
      redirect_to edit_admin_course_step_url(@quiz_question.course_step_id)
    else
      render action: :new
    end
  end

  def update
    if @quiz_question.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.quiz_questions.update.flash.success')
      redirect_to edit_admin_course_step_url(@quiz_question.course_step_id)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      QuizQuestion.find(the_id.to_i).update_attributes!(sorting_order: (counter + 1))
    end

    render json: {}, status: :ok
  end

  def destroy
    if @quiz_question.destroy
      flash[:success] = I18n.t('controllers.quiz_questions.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.quiz_questions.destroy.flash.error')
    end

    redirect_to edit_admin_course_step_url(@quiz_question.course_step_id)
  end

  protected

  def get_variables
    @mathjax_required = true
    @quiz_question =
      if params[:id].to_i.positive?
        ## Finds the qq record ##
        QuizQuestion.find(params[:id])
      elsif params[:quiz_step_id].to_i.positive?
        QuizQuestion.new(course_quiz_id: params[:quiz_step_id])
      else
        QuizQuestion.new(allowed_params)
      end

    @quiz_questions = QuizQuestion.all_in_order
    seo_title_maker("Quiz Questions #{@quiz_question.try(:id)}", '', true)
  end

  def allowed_params
    params.require(:quiz_question).permit(
      :course_quiz_id,
      :difficulty_level,
      :sorting_order,
      quiz_solutions_attributes: [
        :id,
        :quiz_question_id,
        :quiz_answer_id,
        :quiz_solution_id,
        :text_content,
        :sorting_order,
        :_destroy,
        :image
      ],
      quiz_answers_attributes: [
        :id,
        :quiz_question_id,
        :correct,
        :degree_of_wrongness,
        quiz_contents_attributes: [
          :id,
          :quiz_question_id,
          :quiz_answer_id,
          :text_content,
          :sorting_order,
          :_destroy,
          :image
        ]
      ],
      quiz_contents_attributes: [
        :id,
        :quiz_question_id,
        :quiz_answer_id,
        :text_content,
        :sorting_order,
        :_destroy,
        :image
      ]
    )
  end
end
