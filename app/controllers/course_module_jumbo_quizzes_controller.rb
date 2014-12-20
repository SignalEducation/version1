class CourseModuleJumboQuizzesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor'])
  end
  before_action :get_variables

  def new
    @course_module_jumbo_quiz = CourseModuleJumboQuiz.new(course_module_id: params[:cm_id])
  end

  def edit
  end

  def create
    @course_module_jumbo_quiz = CourseModuleJumboQuiz.new(allowed_params)
    if @course_module_jumbo_quiz.save
      flash[:success] = I18n.t('controllers.course_module_jumbo_quizzes.create.flash.success')
      redirect_to course_module_special_link(@course_module_jumbo_quiz.course_module)
    else
      render action: :new
    end
  end

  def update
    if @course_module_jumbo_quiz.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_module_jumbo_quizzes.update.flash.success')
      redirect_to course_module_special_link(@course_module_jumbo_quiz.course_module)
    else
      render action: :edit
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_module_jumbo_quiz = CourseModuleJumboQuiz.where(id: params[:id]).first
    end
    seo_title_maker(@course_module_jumbo_quiz.try(:name))
  end

  def allowed_params
    params.require(:course_module_jumbo_quiz).permit(:course_module_id, :name, :minimum_question_count_per_quiz, :maximum_question_count_per_quiz, :total_number_of_questions)
  end

end
