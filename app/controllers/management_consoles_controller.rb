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

    @students = User.all_students
    @standard_students = User.all_trial_or_sub_students
    @comp_students = User.all_comp_students
    @trial_students = StudentAccess.all_trial
    @valid_trial_students = StudentAccess.all_trial.where(content_access: true)
    @invalid_trial_students = StudentAccess.all_trial.where(content_access: false)
    @sub_students = StudentAccess.all_sub
    @valid_sub_students = StudentAccess.all_sub.where(content_access: true)
    @invalid_sub_students = StudentAccess.all_sub.where(content_access: false)

    @subscriptions = Subscription.all
    @active_subs = Subscription.where(current_status: 'active')
    @past_due_subs = Subscription.where(current_status: 'past_due')
    @cancel_pending_subs = Subscription.where(current_status: 'canceled-pending')
    @cancelled_subs = Subscription.where(current_status: 'canceled')


    @total_enrollments = Enrollment
    @active_enrollments = Enrollment.all_valid
    @expired_enrollments = Enrollment.all_expired
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