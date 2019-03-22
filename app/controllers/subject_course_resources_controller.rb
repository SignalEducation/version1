# == Schema Information
#
# Table name: subject_course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  subject_course_id        :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default(FALSE)
#  sorting_order            :integer
#  available_on_trial       :boolean          default(FALSE)
#

class SubjectCourseResourcesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(content_management_access))
  end
  before_action :get_variables

  def index
    @subject_course_resources = SubjectCourseResource.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @subject_course_resource = SubjectCourseResource.new
  end

  def edit
  end

  def create
    @subject_course_resource = SubjectCourseResource.new(allowed_params)
    if @subject_course_resource.save
      flash[:success] = I18n.t('controllers.subject_course_resources.create.flash.success')
      redirect_to course_resources_url(@subject_course_resource.subject_course)
    else
      render action: :new
    end
  end

  def update
    if @subject_course_resource.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.subject_course_resources.update.flash.success')
      redirect_to course_resources_url(@subject_course_resource.subject_course)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      SubjectCourseResource.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @subject_course_resource.destroy
      flash[:success] = I18n.t('controllers.subject_course_resources.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.subject_course_resources.destroy.flash.error')
    end
    redirect_to subject_course_resources_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @subject_course_resource = SubjectCourseResource.where(id: params[:id]).first
    end
    @subject_courses = SubjectCourse.all_active.all_in_order
    @layout = 'management'
  end

  def allowed_params
    params.require(:subject_course_resource).permit(:name, :subject_course_id, :description,
                                                    :file_upload, :external_url, :active,
                                                    :sorting_order, :available_on_trial)
  end

end
