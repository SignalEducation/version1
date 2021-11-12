# frozen_string_literal: true

class UserEngagementController < ApplicationController
  before_action :logged_out_required, only: %i[new create_user_session_engagement]
  before_action :logged_in_required,  only: :destroy
  before_action :check_user_group, only: :create_user_session_engagement
  before_action :get_variables
  before_action :create_user_object, only: %i[new]
  before_action :create_user_session_object
  layout 'marketing', only: %i[new]

  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.html { render 'user_engagement/new' }
    end
  end

  def create
    user_country = IpAddress.get_country(request.remote_ip, true)
    user_currency = user_country&.currency || Currency.find_by(iso_code: 'GBP')

    @user = User.new(
      student_allowed_params.merge(
        user_group: UserGroup.student_group,
        country: user_country,
        currency: user_currency
      )
    )

    binding.pry

    @user.user_registration_calbacks(params)

    if verify_recaptcha(model: @user) && @user.save
      @user.handle_post_user_creation(user_verification_url(email_verification_code: @user.email_verification_code))
      handle_course_enrollment(@user, params[:course_id]) if params[:course_id]

      # TODO: Refactor this to not use the flash
      if flash[:plan_guid]
        UserSession.create(@user)
        set_current_visit(@user)
        redirect_to new_subscription_url(plan_guid: flash[:plan_guid], exam_body_id: flash[:exam_body], registered: true)
      elsif flash[:product_id]
        UserSession.create(@user)
        set_current_visit(@user)
        redirect_to new_product_order_url(product_id: flash[:product_id], registered: true)
      else
        flash[:datalayer_id] = @user.id
        flash[:datalayer_body] = @user.try(:preferred_exam_body).try(:name)
        UserSession.create(@user)
        set_current_visit(@user)
        redirect_to student_dashboard_url
      end
    elsif request&.referrer
      set_session_errors(@user)
      redirect_to request.referrer
    else
      redirect_to root_url
    end
  rescue ActionController::InvalidAuthenticityToken
    flash[:error] = 'Sorry. Your sign up attempt failed. Please try again'
    redirect_to root_url
  end

  def create_user_session_engagement
    @user_session = UserSession.new(user_session_params.to_h)

    if @user_session.save
      @user_session.user.check_country(request.remote_ip)
      @user_session.user.update_attribute(:session_key, session[:session_id])
      @user_session.user.update_attribute(:analytics_guid, cookies[:_ga]) if cookies[:_ga]
      @user_session.user.update_attributes(password_reset_token: nil, password_reset_requested_at: nil) if @user_session.user.password_reset_token
      set_current_visit(@user_session.user)
      enrollment, flash_message = handle_course_enrollment(@user_session.user, params[:course_id]) if params[:course_id] && !params[:course_id].blank?
      flash[:error] = nil
      flash[:just_signed_in] = true

      if flash[:plan_guid]
        redirect_to new_subscription_url(plan_guid: flash[:plan_guid], exam_body_id: flash[:exam_body], login: true)
      elsif flash[:product_id]
        redirect_to new_product_order_url(product_id: flash[:product_id], login: true)
      elsif session[:return_to]
        redirect_back_or_default(student_dashboard_url)
      elsif params[:course_id]
        enrollment ? flash[:success] = flash_message : flash[:error] = flash_message
        redirect_to course_enrollment_special_link(params[:course_id])
      else
        redirect_to student_dashboard_url, flash: { just_signed_in: true }
      end
      SegmentService.new.identify_user(@user_session.user)
    elsif flash[:plan_guid] || flash[:product_id]
      set_session_errors(@user_session)
      redirect_back(fallback_location: sign_in_url)
    else
      render action: :new
    end
  rescue ActionController::InvalidAuthenticityToken
    flash[:error] = 'Sorry. Your login attempt failed. Please try again'
    redirect_to sign_in_url
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

  def get_variables
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
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
end