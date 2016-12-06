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
  before_action only: [:index, :new, :edit, :update, :create] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables, except: [:student_sign_up, :diploma, :home, :diploma_index]
  before_action :layout_variables, only: [:diploma, :home, :diploma_index, :group_index]

  def home
    #This is the main home_page
    redirect_to dashboard_special_link(current_user) if current_user
    @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
    @subscription_course_category = SubjectCourseCategory.all_active.all_subscription.all_in_order.first
    @product_courses = @product_course_category.subject_courses if @product_course_category
    @subscription_courses = @subscription_course_category.subject_courses if @subscription_course_category
    @groups = Group.all_active.for_public.all_in_order
    @country = IpAddress.get_country(request.remote_ip) || Country.find_by_iso_code('IE')
    seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
  end

  def group_index
    @user = User.new
    # Setting the country and currency by the IP look-up, if it fails both values are set for primary marketing audience (currently GB). This also insures values are set for test environment.
    country = IpAddress.get_country(request.remote_ip)
    if country
      @user.country_id = country.id
      @currency_id = country.currency_id
    else
      gb = Country.find_by_name('United Kingdom')
      @user.country_id = gb.id
      @currency_id = gb.currency_id
    end
    #To allow displaying of sign_up_errors since this is not the users_controller
    session[:sign_up_errors].each do |k, v|
      v.each { |err| @user.errors.add(k, err) }
    end if session[:sign_up_errors]
    session.delete(:sign_up_errors)
    # Don't remember why this needs to be set
    @subscription_plan = SubscriptionPlan.in_currency(@currency_id).where(payment_frequency_in_months: 1).where(subscription_plan_category_id: nil).where('price > 0.0').first

    #To show each pricing plan on the page; not invlolved in the sign up process
    @student_subscription_plans = SubscriptionPlan.where('price > 0.0').where(subscription_plan_category_id: nil).includes(:currency).for_students.in_currency(@currency_id).all_active.all_in_order
    @groups = Group.all_active.for_public.all_in_order
    seo_title_maker('Library', 'Learn anytime, anywhere from our library of business-focused courses taught by expert tutors.', nil)
  end

  def diploma_index
    product = Product.first
    redirect_to product_course_url(product.subject_course.home_pages.first.public_url)
    @country = IpAddress.get_country(request.remote_ip) || Country.find_by_iso_code('IE')
    @currency_id = @country.currency_id
    @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
    @navbar = nil
    @footer = nil
  end

  def group
    @first_element = params[:home_pages_public_url].to_s if params[:home_pages_public_url]
    @default_element = params[:default] if params[:default]
    @subscription_course_category = SubjectCourseCategory.all_active.all_subscription.all_in_order.first
    @country = IpAddress.get_country(request.remote_ip) || Country.find_by_iso_code('IE')
    @home_page = HomePage.find_by_public_url(params[:home_pages_public_url])
    @group = @home_page.try(:group)
    @url_value = @home_page.try(:public_url)
    redirect_to all_groups_url unless @group

    # Create user object and necessary variables
    @user = User.new
    session[:sign_up_errors].each do |k, v|
      v.each { |err| @user.errors.add(k, err) }
    end if session[:sign_up_errors]
    session.delete(:sign_up_errors)
    if @country
      @currency_id = @country.currency_id
      @user.country_id = @country.id
    else
      @currency_id = Currency.find_by_iso_code('GBP').id
      @user.country_id = Country.find_by_name('United Kingdom').id
    end
    @subscription_plan = SubscriptionPlan.in_currency(@currency_id).where(payment_frequency_in_months: 1).where(subscription_plan_category_id: nil).where('price > 0.0').first

    if @home_page
      seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
      cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
    else
      seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
    end
    @navbar = nil
  end

  def diploma
    #Needs to render a custom partial if one exists or render the default
    @first_element = params[:home_pages_public_url].to_s if params[:home_pages_public_url]
    @default_element = params[:default] if params[:default]
    @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
    @country = IpAddress.get_country(request.remote_ip) || Country.find_by_iso_code('IE')
    @home_page = HomePage.find_by_public_url(params[:home_pages_public_url])
    @course = @home_page.subject_course
    @currency_id = @country.currency_id
    @product = @course.products.all_active.in_currency(@currency_id).last
    @navbar = nil
    @footer = nil

  end

  def student_sign_up
    #Duplicate in Users controller
    if current_user
      redirect_to dashboard_special_link(current_user)
    else
      @user = User.new(student_allowed_params)
      @user.user_group_id = UserGroup.default_student_user_group.try(:id)
      @user.student_user_type_id = StudentUserType.default_free_trial_user_type.try(:id)
      @user.country_id = IpAddress.get_country(request.remote_ip).try(:id) || Country.where(iso_code: 'GB').first.id
      @user.account_activation_code = SecureRandom.hex(10)
      @user.email_verification_code = SecureRandom.hex(10)
      @user.password_confirmation = @user.password
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
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(
          email: @user.try(:email)
      )
      @user.stripe_customer_id = stripe_customer.id
      @user.free_trial = true

      if @user.valid? && @user.save
        @subscription_plan = SubscriptionPlan.in_currency(@user.country.currency_id).where(payment_frequency_in_months: 1).where(subscription_plan_category_id: nil).first

        # Send User Email Verification and Use Welcome emails through Mandrill Client
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
        user = User.get_and_activate(@user.account_activation_code)
        @user.create_referral_code
        UserSession.create(user)
        redirect_to personal_sign_up_complete_url
      else        # This is the way to restore model errors after redirect. In referrer method
        # (which in our case can be one of three static pages - root, cfa or acca) we
        # are restoring errors to the @user. Otherwise our redirect would destroy errors
        # and sign-up form would not display them properly.
        session[:sign_up_errors] = @user.errors unless @user.errors.empty?
        redirect_to request.referrer
      end
    end
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
    @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
    @subscription_course_category = SubjectCourseCategory.all_active.all_subscription.all_in_order.first
    @course_home_page_urls = HomePage.for_courses.map(&:public_url)
    @group_home_page_urls = HomePage.for_groups.map(&:public_url)
    @groups = Group.all_active.all_in_order.for_public
    @subject_courses = SubjectCourse.all_active.all_in_order.for_public
  end

  def layout_variables
    @navbar = nil
    @footer = true
  end

  def allowed_params
    params.require(:home_page).permit(:seo_title, :seo_description, :subscription_plan_category_id, :public_url, :group_id, :subject_course_id)
  end

  def student_allowed_params
    params.require(:user).permit(
          :email, :first_name, :last_name,
          :country_id, :locale,
          :password, :password_confirmation,
          :topic_interest
    )
  end
end
