class QuestionBanksController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def new
    @question_bank = QuestionBank.new
    @exam_level = ExamLevel.find_by(name_url: params[:exam_level_name_url])
    max_easy_questions = QuizQuestion.where(exam_level_id: @exam_level.id).where(difficulty_level: 'easy').count
    @easy_array = Array(0..max_easy_questions)
    max_medium_questions = QuizQuestion.where(exam_level_id: @exam_level.id).where(difficulty_level: 'medium').count
    @medium_array = Array(0..max_medium_questions)
    max_hard_questions = QuizQuestion.where(exam_level_id: @exam_level.id).where(difficulty_level: 'difficult').count
    @hard_array = Array(0..max_hard_questions)
  end

  def create
    @question_bank = QuestionBank.new(allowed_params)
    @question_bank.user_id = current_user.id
    @exam_level = ExamLevel.find_by(name_url: params[:exam_level_name_url])
    @question_bank.exam_level_id = @exam_level.id
    @question_bank.question_selection_strategy = 'random'
    if @question_bank.save
      redirect_to course_special_link(@question_bank)
    else
      render action: :new
    end
  end

  def destroy
    if @question_bank.destroy
      flash[:success] = I18n.t('controllers.question_banks.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.question_banks.destroy.flash.error')
    end
    redirect_to library_special_link(@question_bank.exam_level)
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @question_bank = QuestionBank.where(id: params[:id]).first
    end
    @users = User.all_in_order
    @exam_levels = ExamLevel.all_in_order
  end

  def allowed_params
    params.require(:question_bank).permit(:user_id, :exam_level_id, :easy_questions, :medium_questions, :hard_questions)
  end

end
