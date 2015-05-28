class QuestionBanksController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @question_banks = QuestionBank.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @question_bank = QuestionBank.new
  end

  def edit
  end

  def create
    @question_bank = QuestionBank.new(allowed_params)
    @question_bank.user_id = current_user.id
    if @question_bank.save
      flash[:success] = I18n.t('controllers.question_banks.create.flash.success')
      redirect_to question_banks_url
    else
      render action: :new
    end
  end

  def update
    if @question_bank.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.question_banks.update.flash.success')
      redirect_to question_banks_url
    else
      render action: :edit
    end
  end


  def destroy
    if @question_bank.destroy
      flash[:success] = I18n.t('controllers.question_banks.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.question_banks.destroy.flash.error')
    end
    redirect_to question_banks_url
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
    params.require(:question_bank).permit(:user_id, :exam_level_id, :number_of_questions, :easy_questions, :medium_questions, :hard_questions)
  end

end
