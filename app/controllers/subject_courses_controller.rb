class SubjectCoursesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor', 'content_manager'])
  end
  before_action :get_variables

  def index
    if current_user.tutor? && current_user.corporate_customer?
      @subject_courses = SubjectCourse.where(corporate_customer_id: current_user.corporate_customer_id).paginate(per_page: 50, page: params[:page])
    elsif current_user.tutor?
      @subject_courses = SubjectCourse.where(tutor_id: current_user.id).paginate(per_page: 50, page: params[:page]).all_in_order
    else
      @subject_courses = SubjectCourse.paginate(per_page: 50, page: params[:page])
    end
    @courses = params[:search].to_s.blank? ?
        @courses = @subject_courses.all_in_order :
        @courses = @subject_courses.search(params[:search])
  end

  def show
  end

  def new
    if current_user.tutor?
      @subject_course = SubjectCourse.new(sorting_order: 1, tutor_id: current_user.id)
    else
      @subject_course = SubjectCourse.new(sorting_order: 1)
    end
  end

  def edit
  end

  def create
    @subject_course = SubjectCourse.new(allowed_params)
    if current_user.corporate_customer?
      @subject_course.corporate_customer_id = current_user.corporate_customer_id
      @subject_course.live = true
    end
    wistia_response = create_wistia_project(@subject_course.name)
    @subject_course.wistia_guid = wistia_response.hashedId
    if @subject_course.save
      flash[:success] = I18n.t('controllers.subject_courses.create.flash.success')
      redirect_to subject_courses_url
    else
      render action: :new
    end
  end

  def create_wistia_project(name)
    wistia_response = Wistia::Project.create(name: name)
    return wistia_response
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

  protected

  def get_variables
    if params[:id].to_i > 0
      @subject_course = SubjectCourse.where(id: params[:id]).first
    end
    @groups = Group.all_active.all_in_order
    @tutors = User.all_tutors.all_in_order
    @corporate_customers = CorporateCustomer.all_in_order
  end

  def allowed_params
    params.require(:subject_course).permit(:name, :name_url, :sorting_order, :active, :live, :wistia_guid, :tutor_id, :description, :short_description, :mailchimp_guid, :forum_url, :default_number_of_possible_exam_answers, :restricted, :corporate_customer_id, :group_id)
  end

end
