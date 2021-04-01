# frozen_string_literal: true

class UserSessionsController < ApplicationController
  before_action :logged_out_required, only: %i[new create]
  before_action :logged_in_required,  only: :destroy
  before_action :check_user_group, only: :create
  layout 'marketing', only: %i[new]

  def new
    @user_session = UserSession.new
    seo_title_maker('Log in to Start Studying Today | LearnSignal',
                    'Log in to your ACCA or CPD courses to access topic-by-topic tuition modules, explore online learning resources and kick-start your study today.',
                    false)
    respond_to do |format|
      format.html { render 'user_sessions/new' }
    end
  end

  def create
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

  def destroy
    current_user_session.destroy

    redirect_to root_url
  end

  protected

  def user_session_params
    return if params[:user_session].nil?

    params.require(:user_session).permit(:email, :password)
  end

  def handle_course_enrollment(user, course_id)
    Enrollment.create_on_register_login(user, course_id)
  end

  def set_session_errors(user_session)
    session[:login_errors] = user_session.errors unless user_session.errors.empty?
    return if user_session.errors.empty?

    session[:valid_user_session_params] = [user_session.email,user_session.password]
  end

  def check_user_group
    return unless params[:user_session]
    return if params[:user_session].values.any? &:empty?

    user = User.find_by(email: params[:user_session][:email])
    return unless user&.blocked_user?

    flash[:error] = 'Sorry. That account is blocked. Please contact us for assistance.'
    redirect_to sign_in_url
  end
end
