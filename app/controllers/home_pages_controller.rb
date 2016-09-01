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
  before_action :get_variables, except: [:student_sign_up, :diploma, :home, :course]
  before_action :layout_variables, only: [:diploma, :home, :course]

  def index
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order
  end

  def show
    #This is a back up that needs to redirect to course, diploma or home

      @first_element = params[:home_pages_public_url].to_s if params[:home_pages_public_url]
      @default_element = params[:default] if params[:default]

      if @default_element == 'courses_home' || @course_home_page_urls.include?(@first_element) || request.subdomain == 'courses'
        @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
        @courses = @product_course_category.subject_courses
        @country = IpAddress.get_country(request.remote_ip) || Country.find(105)

        if @course_home_page_urls.include?(@first_element)
          #This section is for showing the Course landing pages
          @home_page = HomePage.find_by_public_url(@first_element)
          @course = @home_page.subject_course
          @product = @course.products.in_currency(@country.currency_id).last

        else
          #This section is for showing the Default Course landing page



        end
        render :courses_show
      else

        #This section is for showing the Group landing pages which are also the default
        @home_page = HomePage.find_by_public_url(@first_element)

        # Create user object and necessary variables
        @user = User.new
        session[:sign_up_errors].each do |k, v|
          v.each { |err| @user.errors.add(k, err) }
        end if session[:sign_up_errors]
        session.delete(:sign_up_errors)
        country = IpAddress.get_country(request.remote_ip)
        if country
          @currency_id = country.currency_id
          @user.country_id = country.id
        else
          @currency_id = Currency.find_by_iso_code('GBP').id
          @user.country_id = Country.find_by_name('United Kingdom').id
        end
        @subscription_plan = SubscriptionPlan.in_currency(@currency_id).where(payment_frequency_in_months: 1).where(subscription_plan_category_id: nil).where('price > 0.0').first

        @group = @home_page.try(:group)
        @url_value = @group.try(:name) || params[:home_pages_public_url].to_s.upcase

        if @home_page
          seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
          cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
        else
          seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
        end

      end

  end

  def diploma

      @first_element = params[:home_pages_public_url].to_s if params[:home_pages_public_url]
      @default_element = params[:default] if params[:default]

      if @default_element == 'courses_home' || @course_home_page_urls.include?(@first_element) || request.subdomain == 'courses'
        @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
        @courses = @product_course_category.subject_courses
        @country = IpAddress.get_country(request.remote_ip) || Country.find(105)

        if @course_home_page_urls.include?(@first_element)
          #This section is for showing the Course landing pages
          @home_page = HomePage.find_by_public_url(@first_element)
          @course = @home_page.subject_course
          @product = @course.products.in_currency(@country.currency_id).last

        else
          #This section is for showing the Default Course landing page



        end
        render :courses_show
      else

        #This section is for showing the Group landing pages which are also the default
        @home_page = HomePage.find_by_public_url(@first_element)

        # Create user object and necessary variables
        @user = User.new
        session[:sign_up_errors].each do |k, v|
          v.each { |err| @user.errors.add(k, err) }
        end if session[:sign_up_errors]
        session.delete(:sign_up_errors)
        country = IpAddress.get_country(request.remote_ip)
        if country
          @currency_id = country.currency_id
          @user.country_id = country.id
        else
          @currency_id = Currency.find_by_iso_code('GBP').id
          @user.country_id = Country.find_by_name('United Kingdom').id
        end
        @subscription_plan = SubscriptionPlan.in_currency(@currency_id).where(payment_frequency_in_months: 1).where(subscription_plan_category_id: nil).where('price > 0.0').first

        @group = @home_page.try(:group)
        @url_value = @group.try(:name) || params[:home_pages_public_url].to_s.upcase

        if @home_page
          seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
          cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
        else
          seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
        end

      end

  end

  def home
    #This is the main home_page
    @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
    @subscription_course_category = SubjectCourseCategory.all_active.all_subscription.all_in_order.first
    @product_courses = @product_course_category.subject_courses
    @subscription_courses = @subscription_course_category.subject_courses
    @country = IpAddress.get_country(request.remote_ip) || Country.find(105)
    seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
  end

  def course
      @first_element = params[:home_pages_public_url].to_s if params[:home_pages_public_url]
      @default_element = params[:default] if params[:default]

      if @default_element == 'courses_home' || @course_home_page_urls.include?(@first_element) || request.subdomain == 'courses'
        @product_course_category = SubjectCourseCategory.all_active.all_product.all_in_order.first
        @courses = @product_course_category.subject_courses
        @country = IpAddress.get_country(request.remote_ip) || Country.find(105)

        if @course_home_page_urls.include?(@first_element)
          #This section is for showing the Course landing pages
          @home_page = HomePage.find_by_public_url(@first_element)
          @course = @home_page.subject_course
          @product = @course.products.in_currency(@country.currency_id).last

        else
          #This section is for showing the Default Course landing page



        end
        render :courses_show
      else

        #This section is for showing the Group landing pages which are also the default
        @home_page = HomePage.find_by_public_url(@first_element)

        # Create user object and necessary variables
        @user = User.new
        session[:sign_up_errors].each do |k, v|
          v.each { |err| @user.errors.add(k, err) }
        end if session[:sign_up_errors]
        session.delete(:sign_up_errors)
        country = IpAddress.get_country(request.remote_ip)
        if country
          @currency_id = country.currency_id
          @user.country_id = country.id
        else
          @currency_id = Currency.find_by_iso_code('GBP').id
          @user.country_id = Country.find_by_name('United Kingdom').id
        end
        @subscription_plan = SubscriptionPlan.in_currency(@currency_id).where(payment_frequency_in_months: 1).where(subscription_plan_category_id: nil).where('price > 0.0').first

        @group = @home_page.try(:group)
        @url_value = @group.try(:name) || params[:home_pages_public_url].to_s.upcase

        if @home_page
          seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
          cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
        else
          seo_title_maker('LearnSignal', 'LearnSignal an on-demand training library for business professionals. Learn the skills you need anytime, anywhere, on any device', false)
        end

      end

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

  def student_sign_up
    #Duplicate in Users controller
    if current_user
      redirect_to dashboard_url
    else
      @user = User.new(student_allowed_params)
      @user.user_group_id = UserGroup.default_student_user_group.try(:id)
      @user.country_id = IpAddress.get_country(request.remote_ip).try(:id) || Country.where(iso_code: 'IE').first.id
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
        if @user.topic_interest == 'ACCA'
          MandrillWorker.perform_at(5.minute.from_now, @user.id, 'send_acca_welcome_email', "#{@user.country.currency.leading_symbol}#{@subscription_plan.price}")
        else
          MandrillWorker.perform_at(5.minute.from_now, @user.id, 'send_default_welcome_email', "#{@user.country.currency.leading_symbol}#{@subscription_plan.price}")
        end

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
