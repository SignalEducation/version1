class QuizQuestionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor'])
  end
  before_action :get_variables

  def show
    # This delivers a preview of how the question will look to Users.
  end

  def new
    @quiz_question = QuizQuestion.new(course_module_element_quiz_id: params[:cme_quiz_id])
    @quiz_question.quiz_contents.build
    4.times do
      @quiz_question.quiz_answers.build
      @quiz_question.quiz_answers.last.quiz_contents.build
    end
  end

  def edit
    @quiz_question = QuizQuestion.find(params[:id])
  end

  def create
    redirect_to edit_course_module_element_url(@quiz_question.course_module_element_id)
  end

  def update
    redirect_to edit_course_module_element_url(@quiz_question.course_module_element_id)
  end

  def destroy
  end

  protected

  def get_variables
      @quiz_questions = QuizQuestion.all_in_order
  end

  def allowed_params
    params.require(:quiz_question).permit()
  end

end
