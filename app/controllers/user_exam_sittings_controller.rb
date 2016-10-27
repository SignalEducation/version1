# == Schema Information
#
# Table name: user_exam_sittings
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  exam_sitting_id   :integer
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class UserExamSittingsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'individual_student'])
  end
  before_action :get_variables

  def index
    @user_exam_sittings = UserExamSitting.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @user_exam_sitting = UserExamSitting.new
  end

  def edit
  end

  def create
    exam_sittings = params['user_exam_sittings']
    exam_sittings.each do |exam_sitting|
      sitting = ExamSitting.find(exam_sitting[0])
      @user_exam_sitting = UserExamSitting.create(exam_sitting_id: sitting.id, user_id: current_user.id, subject_course_id: sitting.subject_course_id, date: sitting.date)
    end
    #@user_exam_sitting.date = @user_exam_sitting.exam_sitting.date unless params[:date]
    redirect_to account_url
  end

  def update
    if @user_exam_sitting.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.user_exam_sittings.update.flash.success')
      redirect_to user_exam_sittings_url
    else
      render action: :edit
    end
  end


  def destroy
    if @user_exam_sitting.destroy
      flash[:success] = I18n.t('controllers.user_exam_sittings.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.user_exam_sittings.destroy.flash.error')
    end
    redirect_to user_exam_sittings_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @user_exam_sitting = UserExamSitting.where(id: params[:id]).first
    end
    @users = User.all_in_order
    @exam_sittings = ExamSitting.all_in_order
    @subject_courses = SubjectCourse.all_in_order
  end

  def allowed_params
    params.require(:user_exam_sitting).permit(:user_id, :exam_sitting_id, :subject_course_id, :date)
  end

end
