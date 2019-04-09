class StudentSignUpsController < ApplicationController

  before_action :check_logged_in_status, except: [:landing, :subscribe]
  before_action :get_variables
  before_action :create_user_object, only: [:home, :new, :sign_in_or_register]
  before_action :layout_variables, only: [:home, :landing]

  def home
    @footer = 'white'
    @home_page = HomePage.where(home: true).where(public_url: '/').first
    #@banner = @home_page.external_banners.first
    seo_title_maker(@home_page.seo_title, @home_page.seo_description, @home_page.seo_no_index)
    @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).includes(:currency).in_currency(@currency_id).all_active.all_in_order.limit(3)
    @form_type = 'Home Page Contact'

    #Added respond block to stop the missing template errors with image, text, json types
    respond_to do |format|
      format.html
      format.all { redirect_to(missing_page_url) }
    end
  end

  def landing
    @home_page = HomePage.find_by_public_url(params[:public_url])
    if @home_page
      @public_url = params[:public_url]
      @group = @home_page.group

      if current_user
        ip_country = IpAddress.get_country(request.remote_ip)
        country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
        @currency_id = country.currency_id
      else
        create_user_object
      end

      if @home_page.subscription_plan_category && @home_page.subscription_plan_category.current
        @subscription_plans = @home_page.subscription_plan_category.subscription_plans.for_exam_body(@group.exam_body_id).in_currency(@currency_id).all_active.all_in_order
      else
        @subscription_plans = SubscriptionPlan.where(
            subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id
        ).includes(:currency).in_currency(@currency_id).all_active.all_in_order.limit(3)
      end

      referral_code = ReferralCode.find_by_code(request.params[:ref_code]) if params[:ref_code]
      drop_referral_code_cookie(referral_code) if params[:ref_code] && referral_code
      # This is for sticky sub plans

      seo_title_maker(@home_page.seo_title, @home_page.seo_description, @home_page.seo_no_index)
    else
      redirect_to root_url
    end

    @footer = 'white'
    @form_type = 'Landing Page Contact'
  end

  def sign_in_or_register
    @plan = SubscriptionPlan.where(guid: params[:plan_guid]).last
    @exam_body = ExamBody.where(id: params[:exam_body_id]).last
    @user_session = UserSession.new
    flash[:plan_guid] = @plan.guid if @plan
    flash[:exam_body] = @exam_body.id if @exam_body
  end

  def new
    @navbar = true
    seo_title_maker('Course Membership Registration | LearnSignal',
                    'Become a learnsignal member and access professional course materials, expert notes and corrected questions anytime, anywhere. Choose your plan today.',
                    false)

  end

  def create
    @navbar = false
    @footer = false

    @user = User.new(
      student_allowed_params.merge(
        user_group: UserGroup.student_group,
        country: IpAddress.get_country(request.remote_ip, true)
      )
    )
    @user.pre_creation_setup

    if @user.valid? && @user.save
      handle_post_user_creation(@user)

      if flash[:plan_guid]
        UserSession.create(@user)
        set_current_visit
        redirect_to new_subscription_url(plan_guid: flash[:plan_guid], exam_body_id: flash[:exam_body])
      else
        redirect_to personal_sign_up_complete_url
      end

    elsif request && request.referrer
      set_session_errors(@user)
      redirect_to request.referrer
    else
      redirect_to root_url
    end
  end

  def show
    @banner = nil
    seo_title_maker('Thank You for Registering | LearnSignal',
                    "Thank you for registering to our basic membership plan you can now explore our course content and discover the smarter way to study with learnsignal.",
                    @home_page.seo_no_index)
  end

  def subscribe
    if params[:mailchimp_list_guid] && !params[:mailchimp_list_guid].empty?
      list_id = params[:mailchimp_list_guid]
    else
      list_id = 'a716c282e2' # Newsletter List
    end

    email = params[:email][:address]
    full_name = params[:full_name][:address] if params[:full_name]
    first_name = params[:first_name][:address] if params[:first_name]
    last_name = params[:last_name][:address] if params[:last_name]
    student_number = params[:student_number][:address] if params[:student_number]
    course_name = params[:course]
    date_of_birth = params[:date_of_birth][:address] if params[:date_of_birth]

    if !email.blank?
      begin
        # Bootcamp Guarantee List has Student Number Field other do not
        if params[:student_number]
          @mc.lists.subscribe(list_id, {'email' => email}, {'fname' => full_name,
                                                            'snumber' => student_number,
                                                            'dob' => date_of_birth,
                                                            'coursename' => course_name})
        else
          @mc.lists.subscribe(list_id, {'email' => email}, {'fname' => first_name,
                                                            'lname' => last_name,
                                                            'coursename' => course_name})
        end

        respond_to do |format|
          format.json{render json: {message: 'Success! Check your email to confirm your subscription.'}}
        end
      rescue Mailchimp::ListAlreadySubscribedError
        respond_to do |format|
          format.json{render json: {message: "#{email} is already subscribed to the list"}}
        end
      rescue Mailchimp::ListDoesNotExistError
        respond_to do |format|
          format.json{render json: {message: 'The list could not be found.'}}
        end
      rescue Mailchimp::Error => ex
        if ex.message
          respond_to do |format|
            format.json{render json: {message: 'There was an error. Please enter valid email.'}}
          end
          Rails.logger.error "ERROR: Mailchimp#error - Returned #{ex.message}"
        else
          respond_to do |format|
            format.json{render json: {message: 'An unknown error occurred.'}}
          end
        end
      end
    else
      respond_to do |format|
        format.json{render json: {message: 'Email Address Cannot be blank. Please enter valid email.'}}
      end

    end
  end

  private

  def student_allowed_params
    params.require(:user).permit(
      :email, :first_name, :last_name, :preferred_exam_body_id, :country_id, 
      :locale, :password, :password_confirmation, :terms_and_conditions,
      :communication_approval
    )
  end

  def create_user_object
    @user = User.new
    # Setting the country and currency by the IP look-up, if it fails both values are set for primary marketing audience (currently GB). This also insures values are set for test environment.
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    if @country
      @user.country_id = @country.id
      @currency_id = @country.currency_id
    end
    #To allow displaying of sign_up_errors and valid params since a redirect is used at the end of student_create because it might have to redirect to home or landing actions
    if session[:sign_up_errors] && session[:valid_params]
      session[:sign_up_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end
      @user.first_name = session[:valid_params][0]
      @user.last_name = session[:valid_params][1]
      @user.email = session[:valid_params][2]
      @user.terms_and_conditions = session[:valid_params][3]
      @user.preferred_exam_body_id = session[:valid_params][4]
      session.delete(:sign_up_errors)
      session.delete(:valid_params)
    end
  end

  def check_logged_in_status
    if params[:home_pages_public_url].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: 500
    elsif current_user
      redirect_to student_dashboard_url
    end
  end

  def get_variables
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
  end

  def layout_variables
    @navbar = false
    @top_margin = false
    @footer = true
  end

  def handle_post_user_creation(user)
    user.set_analytics(cookies[:_ga])
    user.activate_user
    user.create_stripe_customer
    user.send_verification_email(
      user_verification_url(email_verification_code: user.email_verification_code)
    )
    user.validate_referral(cookies.encrypted[:referral_data])
    cookies.delete(:referral_data)
  end

  def set_session_errors(user)
    session[:sign_up_errors] = user.errors unless user.errors.empty?
    session[:valid_params] = [
      user.first_name,
      user.last_name,
      user.email,
      user.terms_and_conditions,
      user.preferred_exam_body_id
    ] unless user.errors.empty?
  end
end
