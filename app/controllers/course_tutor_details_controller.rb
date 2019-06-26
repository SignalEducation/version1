class CourseTutorDetailsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(system_requirements_access content_management_access user_management_access))
  end
  before_action :get_variables

  def index
    @course_tutor_details = @subject_course.course_tutor_details.all_in_order
  end

  def new
    @course_tutor_detail = CourseTutorDetail.new(subject_course_id: @subject_course.id, sorting_order: 1)
  end

  def edit
  end

  def create
    @course_tutor_detail = CourseTutorDetail.new(allowed_params)
    if @course_tutor_detail.save
      flash[:success] = I18n.t('controllers.course_tutor_details.create.flash.success')
      redirect_to subject_course_course_tutor_details_url(@subject_course)
    else
      render action: :new
    end
  end

  def update
    if @course_tutor_detail.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_tutor_details.update.flash.success')
      redirect_to subject_course_course_tutor_details_url(@subject_course)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseTutorDetail.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @course_tutor_detail.destroy
      flash[:success] = I18n.t('controllers.course_tutor_details.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_tutor_details.destroy.flash.error')
    end
    redirect_to subject_course_course_tutor_details_url(@subject_course)
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_tutor_detail = CourseTutorDetail.where(id: params[:id]).first
    end
    if params[:subject_course_id].to_i > 0
      @subject_course = SubjectCourse.where(id: params[:subject_course_id]).first
    end
    @layout = 'management'
    @tutor_users = User.all_tutors.all_in_order
  end

  def allowed_params
    params.require(:course_tutor_detail).permit(:subject_course_id, :user_id, :sorting_order, :title)
  end

end
