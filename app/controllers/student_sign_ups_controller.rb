# frozen_string_literal: true

class StudentSignUpsController < ApplicationController
  include ExceptionHandler

  before_action :logged_in_required, except: :create
  before_action :check_logged_in_status, except: %i[show landing group pricing new_landing]
  before_action :get_variables
  before_action :create_user_object, only: %i[new sign_in_or_register sign_in_checkout landing new_landing]
  before_action :create_user_session_object, only: %i[sign_in_or_register sign_in_checkout landing]
  before_action :layout_variables, only: %i[home landing new_landing]
  layout 'marketing'

  def home
    @home_page = HomePage.where(home: true).where(public_url: '/').first
    @vimeo_as_main = vimeo_as_main?

    if @home_page
      seo_title_maker(@home_page.seo_title, @home_page.seo_description, @home_page.seo_no_index)
      @footer = @home_page.footer_option
    else
      seo_title_maker('The Smarter Way to Study | Learnsignal',
                      'Discover learnsignal professional courses designed by experts and delivered online so that you can study on a schedule that suits your learning needs.',
                      false)
      @footer = 'white'
    end
    # TODO, Is this call to get subscription plans needed ??
    @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).includes(:currency).in_currency(@currency_id).all_active.all_in_order.limit(3)
    @form_type = 'Home Page Contact'
    # Added respond block to stop the missing template errors with image, text, json types
    respond_to do |format|
      format.html
      format.all { redirect_to(missing_page_url) }
    end
  end

  def landing
    @home_page = HomePage.find_by(public_url: params[:public_url])

    if @home_page
      @public_url = params[:public_url]
      @group = @home_page.group
      @course = @home_page.course

      if @group
        @exam_body = @group.exam_body

        @currency_id =
          if current_user&.currency_id
            current_user.currency_id
          else
            ip_country = IpAddress.get_country(request.remote_ip)
            country = ip_country || Country.find_by(name: 'United Kingdom')
            country.currency_id
          end

        @course_product = Product.find_by(product_type: :program_access, course_id: @course.id, active: true, currency_id: @currency_id) if @course
        @lifetime_product = Product.find_by(product_type: :lifetime_access, course_id: nil, active: true, currency_id: @currency_id, group_id: @group.id)
        @subscription_plans =
          if @home_page&.subscription_plan_category&.current
            @home_page.subscription_plan_category.subscription_plans.for_exam_body(@group.exam_body_id).in_currency(@currency_id).all_active.all_in_order
          else
            SubscriptionPlan.where(subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id).
              includes(:currency).in_currency(@currency_id).all_active.all_in_order.limit(3)
          end

        @course_tutors = @course.course_tutors.all_in_order if @course
        @preferred_plan = @subscription_plans.where(payment_frequency_in_months: @home_page.preferred_payment_frequency).first
        flash[:plan_guid] = @preferred_plan.guid if @preferred_plan
        flash[:exam_body] = @exam_body.id if @exam_body
        flash[:product_id] = @course_product.id if @course_product

        referral_code = ReferralCode.find_by(code: request.params[:ref_code]) if params[:ref_code]
        drop_referral_code_cookie(referral_code) if params[:ref_code] && referral_code
        # Added respond block to stop the missing template errors with image, text, json types
        respond_to do |format|
          format.html
          format.all { redirect_to(missing_page_url) }
        end
      end
      seo_title_maker(@home_page.seo_title, @home_page.seo_description, @home_page.seo_no_index)
    else
      redirect_to root_url
    end

    @footer = @home_page ? @home_page.footer_option : 'white'
    @form_type = 'Landing Page Contact'
  end

  def sign_in_or_register
    @plan = SubscriptionPlan.where(guid: params[:plan_guid]).last
    @product = Product.where(id: params[:product_id]).last
    @exam_body = ExamBody.where(id: params[:exam_body_id]).last
    flash[:plan_guid] = @plan.guid if @plan
    flash[:exam_body] = @exam_body.id if @exam_body
    flash[:product_id] = @product.id if @product
  end

  def sign_in_checkout
    @plan = SubscriptionPlan.where(guid: params[:plan_guid]).last
    @exam_body = ExamBody.where(id: params[:exam_body_id]).last
    @product = Product.where(id: params[:product_id]).last
    flash[:plan_guid] = @plan.guid if @plan
    flash[:exam_body] = @exam_body.id if @exam_body
  end

  def group
    @group = Group.find_by(name_url: params[:name_url])
    redirect_to root_url and return unless @group&.active && @group&.exam_body&.active
    @exam_body = @group.exam_body
    seo_title_maker(@group.seo_title, @group.seo_description, nil)

    @currency_id =
      if current_user
        current_user.country_id
      else
        ip_country = IpAddress.get_country(request.remote_ip)
        country = ip_country || Country.find_by(name: 'United Kingdom')
        country.currency_id
      end

    if @currency_id
      @subscription_plans = SubscriptionPlan.where(
          subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id
      ).includes(:currency).in_currency(@currency_id).all_active.all_in_display_order.limit(3)
    end

    @navbar = false
    @top_margin = false
    @footer = 'white'
  end

  def new
    @navbar = true
    seo_title_maker('Free Basic Plan Registration | Learnsignal',
                    'Register for our basic membership plan to access your essential course materials and discover the smarter way to study with learnsignal.',
                    false)
  end

  def create
    @navbar = false
    @footer = 'white'
    user_country = IpAddress.get_country(request.remote_ip, true)
    user_currency = user_country&.currency || Currency.find_by(iso_code: 'GBP')

    @user = User.new(
      student_allowed_params.merge(
        user_group: UserGroup.student_group,
        country: user_country,
        currency: user_currency
      )
    )

    @user.user_registration_calbacks(params)

    if verify_user_recaptcha(@user, params['g_recaptcha_response_data']) && @user.save
      @user.handle_post_user_creation(user_verification_url(email_verification_code: @user.email_verification_code))
      handle_course_enrollment(@user, params[:course_id]) if params[:course_id]
      analytics_attributes = params[:analytics_attributes].present? ? JSON.parse(params[:analytics_attributes]) : nil
      SegmentService.new.track_user_account_created_event(@user, analytics_attributes)

      # TODO: Refactor this to not use the flash
      if flash[:plan_guid]
        UserSession.create(@user)
        set_current_visit(@user)
        render json: { url: new_subscription_url(plan_guid: flash[:plan_guid], exam_body_id: flash[:exam_body], registered: true) }, status: :ok
      elsif flash[:product_id]
        UserSession.create(@user)
        set_current_visit(@user)
        render json: { url: new_product_order_url(product_id: flash[:product_id], registered: true) }, status: :ok
      else
        flash[:datalayer_id] = @user.id
        flash[:datalayer_body] = @user.try(:preferred_exam_body).try(:name)
        UserSession.create(@user)
        set_current_visit(@user)
        render json: { url: student_dashboard_url }, status: :ok
      end
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def show
    @banner = nil
    seo_title_maker('Thank You for Registering | Learnsignal',
                    'Thank you for registering to our basic membership plan you can now explore our course content and discover the smarter way to study with learnsignal.',
                    false)
  end

  def pricing
    @exam_bodies = ExamBody.all_active.all_in_order
    @group = Group.find_by(name_url: params[:group_name_url])
    country = IpAddress.get_country(request.remote_ip) || Country.find_by(name: 'United Kingdom')
    @currency =
      if current_user
        current_user.get_currency(country)
      else
        country.currency
      end

    if @group
      @exam_body = @group.exam_body
      @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id).
                              includes(:currency).in_currency(@currency.id).all_active.all_in_display_order
      @products = Product.for_group(@group.id).where(product_type: %i[lifetime_access program_access]).includes(:currency).in_currency(@currency.id).all_active
    else
      @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).
                              includes(:currency).in_currency(@currency.id).all_active.all_in_display_order
      @products = Product.where(product_type: %i[lifetime_access program_access]).includes(:currency).in_currency(@currency.id).all_active
    end

    seo_title_maker(@group&.exam_body&.pricing_seo_title ? "#{@group&.exam_body&.pricing_seo_title} | Learnsignal" : "#{@group&.name} Tuition Plans | Learnsignal",
                    @group&.exam_body&.pricing_seo_description ? @group&.exam_body&.pricing_seo_description : "Achieve your #{@group&.name} learning goals with a learnsignal subscription plan and enjoy professional courses delivered online so that you can study on a schedule that suits you.",
                    false)
  end

  def new_landing
    @home_page = HomePage.find_by(public_url: 'acca-free-lesson')
    @group = @home_page.group
    @exam_body = @group.exam_body
    @currency_id =
      if current_user&.currency_id
        current_user.currency_id
      else
        ip_country = IpAddress.get_country(request.remote_ip)
        country = ip_country || Country.find_by(name: 'United Kingdom')
        country.currency_id
      end

    flash[:exam_body] = @exam_body.id if @exam_body
    respond_to do |format|
      format.html
      format.all { redirect_to(missing_page_url) }
    end

    seo_title_maker(@home_page.seo_title, @home_page.seo_description, @home_page.seo_no_index)
    @footer = 'white'
    @form_type = 'Landing Page Contact'
  end

  private

  def student_allowed_params
    params.require(:user).permit(
      :email, :first_name, :last_name, :preferred_exam_body_id, :country_id,
      :locale, :password, :terms_and_conditions,
      :communication_approval, :home_page_id
    )
  end

  def create_user_object
    @user = User.new
    # Setting the country and currency by the IP look-up, if it fails both values are set for primary marketing audience (currently GB). This also insures values are set for test environment.
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country || Country.find_by(name: 'United Kingdom')
    if @country
      @user.country_id = @country.id
      @currency_id = @country.currency_id
    end

    # To allow displaying of sign_up_errors and valid params since a redirect is used at the end of student_create because it might have to redirect to home or landing actions
    return unless session[:sign_up_errors] && session[:valid_params]

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

  def create_user_session_object
    @user_session = UserSession.new
    # To allow displaying of user_session_errors
    return unless session[:login_errors] && session[:valid_user_session_params]

    session[:login_errors].each do |k, v|
      v.each { |err| @user_session.errors.add(k, err) }
    end
    @user_session.email = session[:valid_user_session_params][0]
    @user_session.password = session[:valid_user_session_params][1]
    session.delete(:login_errors)
    session.delete(:valid_user_session_params)
  end

  def check_logged_in_status
    if params[:home_pages_public_url].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: :internal_server_error
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

  def handle_course_enrollment(user, course_id)
    Enrollment.create_on_register_login(user, course_id)
  end

  def verify_user_recaptcha(user, recaptcha_data)
    key = Rails.application.credentials[Rails.env.to_sym][:google][:recaptcha][:secret_key]
    verify_recaptcha(response: recaptcha_data, model: user, action: 'registration', secret_key: key)
  end

  def set_session_errors(user)
    return if user.errors.empty?

    session[:sign_up_errors] = user.errors
    session[:valid_params] = [user.first_name,
                              user.last_name,
                              user.email,
                              user.terms_and_conditions,
                              user.preferred_exam_body_id]
  end
end
