class StudentSignUpsController < ApplicationController

  before_action :check_logged_in_status
  before_action :get_variables
  before_action :create_user_object, only: [:home, :landing, :new]
  before_action :layout_variables, only: [:home, :landing]

  def home
    @home_page = HomePage.where(home: true).where(public_url: '/').first
    if @home_page
      @group = @home_page.group
      seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
    else
      @group = Group.all_active.all_in_order.first
    end
    @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).includes(:currency).for_students.in_currency(@currency_id).all_active.all_in_order.limit(3)
    @form_type = 'Home Page Contact'
  end

  def landing
    @home_page = HomePage.find_by_public_url(params[:public_url])
    if @home_page
      @group = @home_page.group
      @subject_course = @home_page.subject_course

      #TODO Remove limit(3)
      @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).includes(:currency).for_students.in_currency(@currency_id).all_active.all_in_order.limit(3)

      seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)

      # This is for sticky sub plans
      cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}

    else
      redirect_to root_url
    end

    @form_type = 'Landing Page Contact'
  end

  def subscribe
    email = params[:email][:address]
    name = params[:first_name][:address]
    #list_id = '866fa91d62' # Dev List
    list_id = 'a716c282e2' # Production List
    if !email.blank?
      begin
        @mc.lists.subscribe(list_id, {'email' => email}, {'fname' => name})

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

  def new
    @navbar = true
  end

  def create
    @navbar = false
    @footer = false

    @user = User.new(student_allowed_params)
    student_user_group = UserGroup.where(student_user: true, trial_or_sub_required: true).first
    @user.user_group_id = student_user_group.try(:id)
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @user.account_activation_code = SecureRandom.hex(10)
    @user.email_verification_code = SecureRandom.hex(10)
    @user.password_confirmation = @user.password

    @user.build_student_access(trial_seconds_limit: ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i, trial_days_limit: ENV['FREE_TRIAL_DAYS'].to_i, account_type: 'Trial')

    # Checks for SubscriptionPlanCategory cookie to see if the user should get specific subscription plans instead of the general plans
    if cookies.encrypted[:latest_subscription_plan_category_guid]
      subscription_plan_category = SubscriptionPlanCategory.where(guid: cookies.encrypted[:latest_subscription_plan_category_guid]).first
      @user.subscription_plan_category_id = subscription_plan_category.try(:id)
      @user.student_access.trial_days_limit = subscription_plan_category.trial_period_in_days.to_i
    end

    if @user.valid? && @user.save
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(
          email: @user.try(:email)
      )
      @user.update_attribute(:stripe_customer_id, stripe_customer.id)
      @user.update_attribute(:analytics_guid, cookies[:_ga]) if cookies[:_ga]

      # Send User Activation email through Mandrill
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))

      # Checks for our referral cookie in the users browser and creates a ReferredSignUp associated with this user
      if cookies.encrypted[:referral_data]
        code, referrer_url = cookies.encrypted[:referral_data].split(';')
        if code
          referral_code = ReferralCode.find_by_code(code)
          @user.create_referred_signup(referral_code_id: referral_code.id, referrer_url: referrer_url) if referral_code
          cookies.delete(:referral_data)
        end
      end
      @user.create_referral_code
      redirect_to personal_sign_up_complete_url(@user.account_activation_code)
    else
      session[:sign_up_errors] = @user.errors unless @user.errors.empty?
      session[:valid_params] = [@user.first_name, @user.last_name, @user.email, @user.terms_and_conditions] unless @user.errors.empty?
      redirect_to request.referrer
    end
  end

  def show
    #This is the post sign-up landing page - personal_sign_up_complete
    #If no user is found redirect - because analytics counts loading of
    # this page as new sign ups so we only want it to load once for each sign up
    @user = User.get_and_activate(params[:account_activation_code])
    redirect_to sign_in_url unless @user
  end

  protected

  def student_allowed_params
    params.require(:user).permit(
        :email, :first_name, :last_name,
        :country_id, :locale,
        :password, :password_confirmation,
        :topic_interest, :terms_and_conditions
    )
  end

  def create_user_object
    @user = User.new
    # Setting the country and currency by the IP look-up, if it fails both values are set for primary marketing audience (currently GB). This also insures values are set for test environment.
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @currency_id = @country.currency_id
    #To allow displaying of sign_up_errors and valid params since a redirect is used at the end of student_create because it might have to redirect to home or landing actions
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

end
