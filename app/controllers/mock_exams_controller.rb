# frozen_string_literal: true

class MockExamsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[content_management_access])
  end
  before_action :get_variables

  def index
    @mock_exams = MockExam.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def new
    @mock_exam = MockExam.new
  end

  def edit
    @mock_exam
  end

  def create
    @mock_exam = MockExam.new(allowed_params)

    if @mock_exam.save
      flash[:success] = I18n.t('controllers.mock_exams.create.flash.success')
      redirect_to mock_exams_url
    else
      render action: :new
    end
  end

  def update
    if @mock_exam.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.mock_exams.update.flash.success')
      redirect_to mock_exams_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      MockExam.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end

    render json: {}, status: :ok
  end

  def destroy
    if @mock_exam.destroy
      flash[:success] = I18n.t('controllers.mock_exams.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.mock_exams.destroy.flash.error')
    end
    redirect_to mock_exams_url
  end

  protected

  def get_variables
    @mock_exam = MockExam.where(id: params[:id]).first if params[:id].to_i > 0
    @subject_courses = SubjectCourse.all_active.all_in_order
    @products = Product.all_in_order
    @currencies = Currency.all_in_order
    @layout = 'management'
  end

  def allowed_params
    params.require(:mock_exam).permit(:subject_course_id, :name, :sorting_order, :file, :cover_image)
  end
end
