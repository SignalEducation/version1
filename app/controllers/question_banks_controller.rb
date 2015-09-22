class QuestionBanksController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def new
    @question_bank = QuestionBank.new
    @subject_course = SubjectCourse.where(name_url: params[:subject_course_name_url].to_s).first
    if @subject_course
      n = 5
      max_easy_questions = QuizQuestion.where(subject_course_id: @subject_course.id).where(difficulty_level: 'easy').count
      easy_array = Array(1..max_easy_questions)
      @easy_array = (1.. easy_array.length).select{ |x| x%n == n-1 }.map { |y| easy_array[y] }
      max_medium_questions = QuizQuestion.where(subject_course_id: @subject_course.id).where(difficulty_level: 'medium').count
      medium_array = Array(1..max_medium_questions)
      @medium_array = (1.. medium_array.length).select{ |x| x%n == n-1 }.map { |y| medium_array[y] }
      max_hard_questions = QuizQuestion.where(subject_course_id: @subject_course.id).where(difficulty_level: 'difficult').count
      hard_array = Array(1..max_hard_questions)
      @hard_array = (1.. hard_array.length).select{ |x| x%n == n-1 }.map { |y| hard_array[y] }
    end
  end

  def create
    @question_bank = QuestionBank.new(allowed_params)
    @question_bank.user_id = current_user.id
    url = URI(request.referer).path
    split_url = url.split('/')
    subject_course = SubjectCourse.where(name_url: split_url).first
    @question_bank.subject_course_id = subject_course.try(:id)
    @question_bank.question_selection_strategy = 'random'
    if @question_bank.save
      redirect_to question_bank_url(subject_course.name_url, @question_bank.id)
    else
      flash[:error] = I18n.t('controllers.question_banks.create.flash.error')
      redirect_to new_question_bank_path
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
    @users = User.all_in_order
 end

  def allowed_params
    params.require(:question_bank).permit(:user_id, :easy_questions, :medium_questions, :hard_questions, :subject_course_id)
  end

end
