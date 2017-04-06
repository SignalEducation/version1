class StudentSignUpsController < ApplicationController

  before_action :logged_in_required, only: [:account_verified, :admin_resend_verification_mail]
  before_action :logged_out_required, except: [:account_verified, :admin_resend_verification_mail]
  before_action :get_variables

  def new
    @user = User.new
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @topic_interests = Group.all_active.all_in_order
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
    @navbar = false
    @footer = false
  end

  def create
    @navbar = false
    @footer = false
    @topic_interests = Group.all_active.all_in_order

    @user = User.new(student_allowed_params)
    @user.user_group_id = UserGroup.default_student_user_group.try(:id)
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @user.account_activation_code = SecureRandom.hex(10)
    @user.email_verification_code = SecureRandom.hex(10)
    @user.password_confirmation = @user.password
    @user.free_trial = true

    # Check for CrushOffers cookie and assign it to the User
    if cookies.encrypted[:crush_offers]
      @user.crush_offers_session_id = cookies.encrypted[:crush_offers]
      cookies.delete(:crush_offers)
    end
    # Checks for SubscriptionPlanCategory cookie to see if the user should get specific subscription plans instead of the general plans
    if cookies.encrypted[:latest_subscription_plan_category_guid]
      subscription_plan_category = SubscriptionPlanCategory.where(guid: cookies.encrypted[:latest_subscription_plan_category_guid]).first
      @user.subscription_plan_category_id = subscription_plan_category.try(:id)
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
      @user.assign_anonymous_logs_to_user(current_session_guid)
      @user.create_referral_code
      redirect_to personal_sign_up_complete_url(@user.account_activation_code)
    else
      session[:sign_up_errors] = @user.errors unless @user.errors.empty?
      session[:valid_params] = [@user.first_name, @user.last_name, @user.email, @user.terms_and_conditions] unless @user.errors.empty?
      redirect_to request.referrer
    end
  end

  #This is the post sign-up landing page.
  def show
    @user = User.get_and_activate(params[:account_activation_code])
    redirect_to root_url unless @user
  end

  #This is the post email verification page
  def account_verified
    if current_user.topic_interest.present?
      home_page = HomePage.where(public_url: current_user.topic_interest.downcase).first
      @group = home_page.group if home_page
    end
    @groups = Group.all_active.all_in_order
  end

  def resend_verification_mail
    @user = User.find_by_email_verification_code(params[:email_verification_code])
    if @user
      flash[:success] = I18n.t('controllers.home_pages.resend_verification_mail.flash.success')
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))
    else
      redirect_to(root_url)
    end
  end

  def admin_resend_verification_mail
    @user = User.find_by_email_verification_code(params[:email_verification_code])
    if @user
      flash[:success] = 'Verification Email sent'
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))
      redirect_to users_url
    else
      flash[:error] = 'Verification Email was not sent'
      redirect_to users_url
    end
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

  def get_variables
    @courses = SubjectCourse.all_active.all_live.all_in_order
  end
end
