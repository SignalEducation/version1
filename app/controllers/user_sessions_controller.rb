class UserSessionsController < ApplicationController

  before_filter :logged_out_required, only: [:new, :create]
  before_filter :logged_in_required,  only: :destroy
  before_filter :set_variables
  before_filter :check_email_verification, only: [:create]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(allowed_params)
    if @user_session.save
      @user_session.user.update_attribute(:session_key, session[:session_id])
      @user_session.user.update_attribute(:analytics_guid, cookies[:_ga]) if cookies[:_ga]
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
    #TODO review this
    user = User.find_by_email(params[:user_session][:email])
    if user && user.student_user? && !user.email_verified
      flash[:warning] = "The email for that account has not been verified. Please follow the instructions in the verification email we just sent you at #{user.email}"
      user.update_attribute(:email_verification_code, SecureRandom.hex(10)) unless user.email_verification_code
      MandrillWorker.perform_async(user.id, 'send_verification_email', user_verification_url(email_verification_code: user.email_verification_code))
      redirect_to sign_in_url
    end
  end

  def set_variables
    @seo_title = 'LearnSignal | Sign In'
    @seo_description = "Sign In here to access LearnSignal's online courses"
  end

end
