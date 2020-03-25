# frozen_string_literal: true

class ExamSittingsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access content_management_access])
  end
  before_action :management_layout
  before_action :get_variables

  def index
    @sort_choices = ExamSitting::SORT_OPTIONS

    @exam_sittings =
      case params[:sort_by]
      when 'all'
        ExamSitting.paginate(per_page: 50, page: params[:page]).all_in_order
      when 'not-active'
        ExamSitting.all_not_active.paginate(per_page: 50, page: params[:page]).all_in_order
      else
        ExamSitting.all_active.paginate(per_page: 50, page: params[:page]).all_in_order
      end
  end

  def show; end

  def new
    @exam_sitting = ExamSitting.new
  end

  def edit; end

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
    if @exam_sitting.update_attributes(update_params)
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

  def export_exam_sitting_enrollments
    @exam_sitting = ExamSitting.find(params[:id])
    @enrollments = @exam_sitting.enrollments

    respond_to do |format|
      format.html
      format.csv { send_data @enrollments.to_csv() }
      format.xls { send_data @enrollments.to_csv(col_sep: "\t", headers: true), filename: "exam-sitting-#{@exam_sitting.id}-#{Date.today}.xls" }
    end
  end

  protected

  def get_variables
    @exam_sitting    = ExamSitting.where(id: params[:id]).first if params[:id].to_i > 0
    @exam_bodies     = ExamBody.all_in_order
    @courses         = Course.all_active.all_in_order
  end

  def allowed_params
    params.require(:exam_sitting).permit(:name, :course_id, :date, :exam_body_id, :active, :computer_based)
  end

  def update_params
    params.require(:exam_sitting).permit(:name, :course_id, :exam_body_id, :active)
  end
end
