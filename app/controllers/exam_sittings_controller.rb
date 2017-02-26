# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  exam_body_id      :integer
#

class ExamSittingsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables

  def index
    @exam_sittings = ExamSitting.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @exam_sitting = ExamSitting.new
  end

  def edit
  end

  def create
    @exam_sitting = ExamSitting.new(allowed_params)
    if @exam_sitting.save
      flash[:success] = I18n.t('controllers.exam_sittings.create.flash.success')
      redirect_to exam_sittings_url
    else
      render action: :new
    end
  end

  def update
    if @exam_sitting.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.exam_sittings.update.flash.success')
      redirect_to exam_sittings_url
    else
      render action: :edit
    end
  end


  def destroy
    if @exam_sitting.destroy
      flash[:success] = I18n.t('controllers.exam_sittings.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.exam_sittings.destroy.flash.error')
    end
    redirect_to exam_sittings_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @exam_sitting = ExamSitting.where(id: params[:id]).first
    end
    @subject_courses = SubjectCourse.all_active.all_live.for_public.all_in_order
    @exam_bodies = ExamBody.all_in_order
  end

  def allowed_params
    params.require(:exam_sitting).permit(:name, :subject_course_id, :date, :exam_body_id)
  end

end
