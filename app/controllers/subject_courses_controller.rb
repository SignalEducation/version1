# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  email_content                           :text
#  external_url_name                       :string
#  external_url                            :string
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#  total_estimated_time_in_seconds         :integer
#  background_image_file_name              :string
#  background_image_content_type           :string
#  background_image_file_size              :integer
#  background_image_updated_at             :datetime
#  preview                                 :boolean          default(FALSE)
#

class SubjectCoursesController < ApplicationController

  # Before Actions #
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(content_management_access))
  end
  before_action :get_variables


  # Standard Actions #
  def index
    @subject_courses = SubjectCourse.paginate(per_page: 50, page: params[:page])
    @courses = params[:search].to_s.blank? ?
        @courses = @subject_courses.all_in_order :
        @courses = @subject_courses.search(params[:search])
  end

  def show
  end

  def new
    @subject_course = SubjectCourse.new(sorting_order: 1)
  end

  def create
    @subject_course = SubjectCourse.new(allowed_params)
    if @subject_course.save
      flash[:success] = I18n.t('controllers.subject_courses.create.flash.success')
      redirect_to subject_courses_url
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @subject_course.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.subject_courses.update.flash.success')
      redirect_to subject_courses_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      SubjectCourse.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @subject_course.destroy
      flash[:success] = I18n.t('controllers.subject_courses.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.subject_courses.destroy.flash.error')
    end
    redirect_to subject_courses_url
  end


  # Non-standard Actions #

  ## Index, New & Create Actions for SubjectCourseResources that belong_to this SubjectCourse ##
  def subject_course_resources
    @subject_course = SubjectCourse.find(params[:id])
    @subject_course_resources = @subject_course.subject_course_resources
  end

  def new_subject_course_resources
    @subject_course = SubjectCourse.find(params[:id])
    @subject_course_resource = SubjectCourseResource.new(subject_course_id: @subject_course.id)
  end

  def create_subject_course_resources
    @subject_course = SubjectCourse.find(params[:id])
    @subject_course_resource = SubjectCourseResource.new(resource_allowed_params)
    @subject_course_resource.subject_course_id = @subject_course.id
    if @subject_course_resource.save
      flash[:success] = I18n.t('controllers.subject_course_resources.create.flash.success')
      redirect_to subject_course_url(@subject_course)
    else
      render action: :new_subject_course_resources
    end
  end


  ## Edit & Update Actions for Tutor Users associated with this SubjectCourse ##
  def edit_tutors
    @subject_course = SubjectCourse.find(params[:subject_course_id]) rescue nil
    @tutor_group = UserGroup.where(tutor: true).first
    @tutors = @tutor_group.users
    all_tutors = @tutors.each_slice( (@tutors.size/2.0).round ).to_a
    @first_tutors = all_tutors.first
    @second_tutors = all_tutors.last
    if @subject_course.nil?
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to subject_courses_url
    end
  end

  def update_tutors
    # TODO Review this - why the conditional
    @subject_course = SubjectCourse.find(params[:subject_course_id]) rescue nil
    if @subject_course && current_user.content_management_access?
      if params[:subject_course]
        @subject_course.user_ids = params[:subject_course][:user_ids]
      else
        @subject_course.user_ids = []
      end

      flash[:success] = I18n.t('controllers.subject_courses.update_subjects.flash.success')
      redirect_to subject_courses_url
    else
      render action: :edit_tutors
    end
  end


  ## Misc Actions ##

  ### Creates list of the Course's CourseModules for Drag&Drop reordering (posted to CourseModules#reorder) ###
  def course_modules_order
    @course_modules = @subject_course.children
  end

  ### Triggered by a CronTask ###
  def update_student_exam_tracks
    subject_course = SubjectCourse.where(id: params[:id]).first
    subject_course.update_all_course_sets
    redirect_to subject_course_url(subject_course)
  end


  protected

  def get_variables
    if params[:id].to_i > 0
      @subject_course = SubjectCourse.where(id: params[:id]).first
    end
    @groups = Group.all_active.all_in_order
    @tutors = User.all_tutors.all_in_order
    @exam_bodies = ExamBody.all_in_order
    @layout = 'management'
  end

  def allowed_params
    params.require(:subject_course).permit(:name, :name_url, :sorting_order,
                                           :active, :tutor_id, :description,
                                           :short_description,
                                           :default_number_of_possible_exam_answers,
                                           :email_content, :external_url,
                                           :external_url_name, :exam_body_id,
                                           :background_image, :survey_url,
                                           :quiz_pass_rate, :group_id, :preview)
  end

  def resource_allowed_params
    params.require(:subject_course_resource).permit(:name, :subject_course_id,
                                                    :description, :file_upload)
  end

end
