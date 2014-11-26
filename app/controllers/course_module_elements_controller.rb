class CourseModuleElementsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor'])
  end
  before_action :get_variables

  def show
  end

  def new
    @course_module_element = CourseModuleElement.new(
        sorting_order: (CourseModuleElement.all.maximum(:sorting_order) + 1),
        tutor_id: current_user.id,
        course_module_id: 1)
    if params[:type] == 'video'
      @course_module_element.build_course_module_element_video
    end
  end

  def edit
  end

  def create
    @course_module_element = CourseModuleElement.new(allowed_params)
    @course_module_element.build_course_module_element_video(video_params)
    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.create.flash.success')
      redirect_to course_module_special_link(@course_module_element.course_module)
    else
      render action: :new
    end
  end

  def update
    #@course_module_element.build_course_module_element_video(video_params)
    if @course_module_element.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_module_elements.update.flash.success')
      redirect_to course_module_special_link(@course_module_element.course_module)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseModuleElement.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @course_module_element.destroy
      flash[:success] = I18n.t('controllers.course_module_elements.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_module_elements.destroy.flash.error')
    end
    redirect_to course_module_elements_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_module_element = CourseModuleElement.where(id: params[:id]).first
    end
    @tutors = User.all_tutors.all_in_order
    @raw_video_files = RawVideoFile.not_yet_assigned.all_in_order
  end

  def allowed_params
    params.require(:course_module_element).permit(:name, :name_url, :description, :estimated_time_in_seconds, :course_module_id, :course_module_element_video_id, :course_module_element_quiz_id, :sorting_order, :forum_topic_id, :tutor_id, :related_quiz_id, :related_video_id, course_module_element_video_attributes: [:course_module_element_id, :id, :raw_video_file_id, :tags, :difficulty_level, :estimated_study_time_seconds, :transcript])
  end

  def video_params
    params[:course_module_element].require(:course_module_element_video_attributes).permit(:course_module_element_id, :id, :raw_video_file_id, :tags, :difficulty_level, :estimated_study_time_seconds, :transcript)
  end

end
