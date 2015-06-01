class QuestionBanksController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def new
    @question_bank = QuestionBank.new
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
      flash[:success] = I18n.t('controllers.question_banks.create.flash.error')
      redirect_to library_special_link(@exam_level)
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
