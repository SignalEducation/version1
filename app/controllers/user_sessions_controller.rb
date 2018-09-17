class UserSessionsController < ApplicationController

  before_filter :logged_out_required, only: [:new, :create]
  before_filter :logged_in_required,  only: :destroy
  before_filter :set_variables
  before_filter :check_email_verification, only: [:create]
  before_filter :check_user_group, only: [:create]

  def new
    @user_session = UserSession.new
    render 'user_sessions/new'
  end

  def create
    @user_session = UserSession.new(allowed_params)
    if @user_session.save
      @user_session.user.update_attribute(:session_key, session[:session_id])
      @user_session.user.update_attribute(:analytics_guid, cookies[:_ga]) if cookies[:_ga]
      @user_session.user.update_attributes(password_reset_token: nil, password_reset_requested_at: nil) if @user_session.user.password_reset_token
      set_current_visit
      flash[:error] = nil
      if session[:return_to]
        redirect_back_or_default(student_dashboard_url)
      else
        redirect_to student_dashboard_url, flash: { just_signed_in: true }
      end
    else
      render action: :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to root_url
  end

  protected

  def allowed_params
    params.require(:user_session).permit(:email, :password)
  end

  def check_email_verification
    user = User.find_by_email(params[:user_session][:email])
    if user && user.student_user? && !user.email_verified
      flash[:warning] = 'Sorry, that email is not verified. Please follow the instructions in the verification email we sent. Or contact us for assistance.'
      MandrillWorker.perform_async(user.id, 'send_verification_email', user_verification_url(email_verification_code: user.email_verification_code)) if user.email_verification_code
      redirect_to sign_in_url
    elsif user && user.email_verified && user.password_change_required
      flash[:warning] = 'Sorry, that email is not verified. Please follow the instructions in the verification email we sent. Or contact us for help.'
      MandrillWorker.perform_async(user.id, 'send_set_password_email', set_password_url(user.password_reset_token))
      redirect_to sign_in_url
    end
  end

  def check_user_group
    user = User.find_by_email(params[:user_session][:email])
    if user && user.blocked_user?
      flash[:error] = 'Sorry. That account is blocked. Please contact us for assistance.'
      redirect_to sign_in_url
    end
  end

  def set_variables
    @seo_title = 'LearnSignal | Sign In'
    @seo_description = "Sign In here to access LearnSignal's online courses"
  end

end
