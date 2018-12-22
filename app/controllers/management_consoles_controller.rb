class ManagementConsolesController < ApplicationController

  before_action :logged_in_required
  before_action except: [:system_requirements] do
    ensure_user_has_access_rights(%w(non_student_user))
  end
  before_action only: [:system_requirements] do
    ensure_user_has_access_rights(%w(marketing_resources_access system_requirements_access))
  end
  before_action :get_variables


  def index
    #TODO allow tutor users navigate to this page
    #TODO and have it display general stats on their courses
    #Default view for all management users. General stats on site - user number, sub numbers, enrollment numbers, course numbers
    @users_count = StudentAccess.count
    @subscriptions = Subscription.with_state(:active).count
    @valid_trial_users = StudentAccess.all_trial.where(content_access: true).count
    @invalid_trial_users = StudentAccess.all_trial.where(content_access: false).count
    @active_courses = SubjectCourse.all_active.count
    @active_course_modules = CourseModule.all_active.count
    @active_groups = Group.all_active.count
    active_cmes = CourseModuleElement.all_active
    @active_videos = active_cmes.all_videos.count
    @active_quizzes = active_cmes.all_quizzes.count
    @total_enrollments = Enrollment.count
    @active_enrollments = Enrollment.all_active.count

  end

  def system_requirements
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order
  end

  def public_resources
    @faq_sections = FaqSection.paginate(per_page: 50, page: params[:page]).all_in_order
  end



  protected

  def get_variables
    @layout = 'management'
  end

end