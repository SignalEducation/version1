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
    @compulsory_courses = ExamLevel.where(id: @corporate_customer.corporate_groups.map { |cg| cg.compulsory_level_ids}.flatten ) +
                          ExamSection.where(id: @corporate_customer.corporate_groups.map { |cg| cg.compulsory_section_ids}.flatten )
    exam_tracks = StudentExamTrack.where(user_id: @corporate_customer.students.pluck(:id))
    started_levels = ExamLevel.where(id: exam_tracks.where("exam_level_id is not null and exam_section_id is null").pluck(:exam_level_id)).where.not(id: @corporate_customer.corporate_groups.map { |cg| cg.compulsory_level_ids}.flatten )
    started_sections = ExamSection.where(id: exam_tracks.where("exam_section_id is not null").pluck(:exam_section_id)).where.not(id: @corporate_customer.corporate_groups.map { |cg| cg.compulsory_section_ids}.flatten )
    @started_courses = started_levels + started_sections

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
    @compulsory_level_cms = CourseModule.where(exam_level_id: @compulsory_courses).map(&:id)
    @compulsory_section_cms = CourseModule.where(exam_section_id: @compulsory_courses).map(&:id)

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
      if request.referrer && request.referrer.include?("profile")
        redirect_to profile_url
      else
        redirect_to corporate_customers_url
      end
    else
      if request.referrer && request.referrer.include?("profile")
        redirect_to profile_url
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
    params.require(:corporate_customer).permit(:organisation_name,
                                               :address,
                                               :country_id,
                                               :payments_by_card,
                                               :stripe_customer_guid,
                                               :logo)
  end

end
