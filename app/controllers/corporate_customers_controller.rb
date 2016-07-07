# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  organisation_name    :string
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  stripe_customer_guid :string
#  created_at           :datetime
#  updated_at           :datetime
#  logo_file_name       :string
#  logo_content_type    :string
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#  subdomain            :string
#  user_name            :string
#  passcode             :string
#  external_url         :string
#  footer_border_colour :string           default("#EFF3F6")
#

class CorporateCustomersController < ApplicationController

  before_action :logged_in_required
  before_action only: [:update, :show] do
    ensure_user_is_of_type(['admin', 'corporate_customer'])
  end
  before_action except: [:update, :show] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @corporate_customers = CorporateCustomer.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
    redirect_to dashboard_url if current_user.corporate_customer? && current_user.corporate_customer_id != params[:id].to_i
    @compulsory_courses = SubjectCourse.all_active.all_live.where(id: @corporate_customer.corporate_groups.map { |cg| cg.compulsory_subject_course_ids}.flatten )
    corp_student_ids = @corporate_customer.students.pluck(:id)
    corp_manager_ids = @corporate_customer.managers.pluck(:id)
    corp_user_ids = corp_student_ids + corp_manager_ids
    exam_tracks = StudentExamTrack.where(user_id: corp_user_ids)
    @started_courses = SubjectCourse.where(id: exam_tracks.pluck(:subject_course_id)).where.not(id: @corporate_customer.corporate_groups.map { |cg| cg.compulsory_subject_course_ids}.flatten )

    #Graph Dates Data
    date_to  = Date.parse("#{Proc.new{Time.now}.call}")
    date_from = date_to - 5.months
    date_range = date_from..date_to
    date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
    @labels = date_months.map {|d| d.strftime "%B" }

    #CourseModuleElementUserLogs Video Data
    video_logs = CourseModuleElementUserLog.where(is_video: true)
    @corporate_videos_logs = video_logs.where(corporate_customer_id: @corporate_customer.id)
    @videos_this_month = @corporate_videos_logs.this_month.count
    @videos_one_month_ago = @corporate_videos_logs.one_month_ago.count
    @videos_two_months_ago = @corporate_videos_logs.two_months_ago.count
    @videos_three_months_ago = @corporate_videos_logs.three_months_ago.count
    @videos_four_months_ago = @corporate_videos_logs.four_months_ago.count
    @videos_five_months_ago = @corporate_videos_logs.five_months_ago.count

    #CourseModuleElementUserLogs Quiz Data
    quiz_logs = CourseModuleElementUserLog.where(is_quiz: true)
    @corporate_quiz_logs = quiz_logs.where(corporate_customer_id: @corporate_customer.id)
    @quizzes_this_month = @corporate_quiz_logs.this_month.count
    @quizzes_one_month_ago = @corporate_quiz_logs.one_month_ago.count
    @quizzes_two_months_ago = @corporate_quiz_logs.two_months_ago.count
    @quizzes_three_months_ago = @corporate_quiz_logs.three_months_ago.count
    @quizzes_four_months_ago = @corporate_quiz_logs.four_months_ago.count
    @quizzes_five_months_ago = @corporate_quiz_logs.five_months_ago.count
    @compulsory_course_cms = CourseModule.where(subject_course_id: @compulsory_courses).map(&:id)

    #Admin Data
    @corporate_students = @corporate_customer.students
    @corporate_managers = @corporate_customer.managers
    @footer = nil
  end

  def new
    @corporate_customer = CorporateCustomer.new
  end

  def edit
  end

  def create
    @corporate_customer = CorporateCustomer.new(allowed_params)
    if @corporate_customer.save
      flash[:success] = I18n.t('controllers.corporate_customers.create.flash.success')
      redirect_to corporate_customers_url
    else
      render action: :new
    end
  end

  def update
    if @corporate_customer.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.corporate_customers.update.flash.success')
      if request.referrer && request.referrer.include?("account")
        redirect_to account_url
      else
        redirect_to corporate_customers_url
      end
    else
      if request.referrer && request.referrer.include?("account")
        redirect_to account_url
      else
        render action: :edit
      end
    end
  end

  def destroy
    if @corporate_customer.destroy
      flash[:success] = I18n.t('controllers.corporate_customers.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_customers.destroy.flash.error')
    end
    redirect_to corporate_customers_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @corporate_customer = CorporateCustomer.where(id: params[:id]).first
    end
    @countries = Country.all_in_order
    seo_title_maker(@corporate_customer.try(:organisation_name) || 'Corporate Customers', '', true)
  end

  def allowed_params
    params.require(:corporate_customer).permit(:organisation_name, :address,
:country_id, :payments_by_card, :stripe_customer_guid, :logo, :subdomain, :user_name, :passcode, :external_url, :footer_border_colour)
  end

end
