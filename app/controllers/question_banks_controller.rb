class QuestionBanksController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor', 'content_manager'])
  end
  before_action :get_variables

  def new
    @question_bank = QuestionBank.new
    @subject_course = SubjectCourse.where(id: params[:sc_id].to_s).first
    if @subject_course
      n = 5
      quizzes = CourseModuleElementQuiz.where(is_final_quiz: true).all.map(&:id)
      max_questions = QuizQuestion.where(subject_course_id: @subject_course.id).where(course_module_element_quiz_id: quizzes).count
      array = Array(1..max_questions)
      @question_array = (1.. array.length).select{ |x| x%n == n-1 }.map { |y| array[y] }
    end
  end

  def create
    @question_bank = QuestionBank.new(allowed_params)
    @question_bank.question_selection_strategy = 'random'
    if @question_bank.save
      redirect_to subject_course_url(@question_bank.subject_course)
    else
      flash[:error] = I18n.t('controllers.question_banks.create.flash.error')
      render action: :new
    end
  end

  def edit
    @subject_course = SubjectCourse.where(id: params[:sc_id].to_s).first
    if @subject_course
      n = 5
      quizzes = CourseModuleElementQuiz.where(is_final_quiz: true).all.map(&:id)
      max_questions = QuizQuestion.where(subject_course_id: @subject_course.id).where(course_module_element_quiz_id: quizzes).count
      array = Array(1..max_questions)
      @question_array = (1.. array.length).select{ |x| x%n == n-1 }.map { |y| array[y] }
    end

  end

  def update
    if @question_bank.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.question_banks.update.flash.success')
      redirect_to subject_course_url(@question_bank.subject_course)
    else
      render action: :edit
    end
  end

  def destroy
    if @question_bank.destroy
      redirect_to library_special_link(@question_bank.subject_course)
    else
      redirect_to library_special_link(@question_bank.subject_course)
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @question_bank = QuestionBank.where(id: params[:id]).first
    end
 end

  def allowed_params
    params.require(:question_bank).permit(:subject_course_id, :number_of_questions, :name, :active)
  end

end
