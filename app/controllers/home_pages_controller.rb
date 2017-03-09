# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  group_id                      :integer
#  subject_course_id             :integer
#

class HomePagesController < ApplicationController

  before_action :logged_in_required, only: [:index, :new, :edit, :update, :create]
  before_action :logged_out_required, only: [:home, :group, :subscribe]
  before_action except: [:home, :group, :subscribe] do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables, except: [:home]
  before_action :layout_variables, only: [:home]
  before_action :create_user_object, only: [:home, :group]

  def home
    #This is the main home_page
    @groups = Group.all_active.all_in_order
    # Displaying the monthly price at top of page
    @subscription_plan = SubscriptionPlan.for_students.all_active.generally_available.in_currency(@currency_id).where(payment_frequency_in_months: 1).first
    #To show each pricing plan on the page; not involved in the sign up process
    @student_subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).includes(:currency).for_students.in_currency(@currency_id).all_active.all_in_order
    @groups = Group.all_active.all_in_order

    seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
  end

  def group
    # Ensuring that the correct params are present for home_page with a valid group and url is present so that the right view file or the default view is loaded
    @first_element = params[:home_pages_public_url].to_s if params[:home_pages_public_url]
    @default_element = params[:default] if params[:default]
    @home_page = HomePage.find_by_public_url(params[:home_pages_public_url])
    @group = @home_page.try(:group)
    @url_value = @home_page.try(:public_url)
    redirect_to root_url unless @group

    # Displaying the monthly price
    @subscription_plan = SubscriptionPlan.for_students.all_active.generally_available.in_currency(@currency_id).where(payment_frequency_in_months: 1).first

    if @home_page
      seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
      cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
    else
      seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
    end
    @navbar = nil
  end

  def subscribe
    email = params[:email][:address]
    list_id = 'a716c282e2'
    if !email.blank?
      begin
        @mc.lists.subscribe(list_id, {'email' => email})
        respond_to do |format|
          format.json{render json: {message: "Success! Check your email to confirm your subscription."}}
        end
      rescue Mailchimp::ListAlreadySubscribedError
        respond_to do |format|
          format.json{render json: {message: "#{email} is already subscribed to the list"}}
        end
      rescue Mailchimp::ListDoesNotExistError
        respond_to do |format|
          format.json{render json: {message: "The list could not be found."}}
        end
      rescue Mailchimp::Error => ex
        if ex.message
          respond_to do |format|
            format.json{render json: {message: "There is an error. Please enter valid email id."}}
          end
        else
          respond_to do |format|
            format.json{render json: {message: "An unknown error occurred."}}
          end
        end
      end
    else
      respond_to do |format|
        format.json{render json: {message: "Email Address Cannot be blank. Please enter valid email id."}}
      end
    end
  end

  def index
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order
  end

  def new
    @home_page = HomePage.new
  end

  def edit
  end

  def create
    @home_page = HomePage.new(allowed_params)
    if @home_page.save
      flash[:success] = I18n.t('controllers.home_pages.create.flash.success')
      redirect_to home_pages_url
    else
      render action: :new
    end
  end

  def update
    if @home_page.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.home_pages.update.flash.success')
      redirect_to home_pages_url
    else
      render action: :edit
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @home_page = HomePage.where(id: params[:id]).first
    end
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
    @course_home_page_urls = HomePage.for_courses.map(&:public_url)
    @group_home_page_urls = HomePage.for_groups.map(&:public_url)
    @groups = Group.all_active.all_in_order
    @subject_courses = SubjectCourse.all_active.all_in_order
  end

  def create_user_object
    @user = User.new
    # Setting the country and currency by the IP look-up, if it fails both values are set for primary marketing audience (currently GB). This also insures values are set for test environment.
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @currency_id = @country.currency_id
    #To allow displaying of sign_up_errors and valid params since a redirect is used at the end of student_create because it might have to redirect to home_pages controller
    if session[:sign_up_errors] && session[:valid_params]
      session[:sign_up_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end
      @user.first_name = session[:valid_params][0]
      @user.last_name = session[:valid_params][1]
      @user.email = session[:valid_params][2]
      @user.terms_and_conditions = session[:valid_params][3]
      session.delete(:sign_up_errors)
      session.delete(:valid_params)
    end
  end

  def layout_variables
    @navbar = nil
    @footer = true
  end

  def allowed_params
    params.require(:home_page).permit(:seo_title, :seo_description, :subscription_plan_category_id, :public_url, :group_id, :subject_course_id)
  end

end
