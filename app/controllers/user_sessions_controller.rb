class UserSessionsController < ApplicationController

  before_filter :logged_out_required, only: [:new, :create]
  before_filter :logged_in_required,  only: :destroy
  before_filter :set_variables
  before_filter :check_email_verification, only: [:create]

  def new
    @navbar = nil
    @footer = nil
    @user_session = UserSession.new
  end

  def create
    @navbar = nil
    @footer = nil
    @user_session = UserSession.new(allowed_params)
    if @user_session.save
      @user_session.user.assign_anonymous_logs_to_user(current_session_guid)
      @user_session.user.update_attribute(:session_key, session[:session_id])
      flash[:error] = nil
      if @user_session.user.corporate_customer?
        redirect_back_or_default corporate_customer_url(@user_session.user.corporate_customer.try(:id), subdomain: @user_session.user.corporate_customer.try(:subdomain))
      elsif @user_session.user.corporate_student?
        redirect_back_or_default corporate_student_dashboard_url(subdomain: @user_session.user.corporate_customer.try(:subdomain))
      elsif session[:return_to]
        redirect_back_or_default dashboard_special_link(@user_session.user)
      else
        redirect_to dashboard_special_link(@user_session.user), flash: { just_signed_in: true }
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
    if !user.email_verified && user.individual_student?
      flash[:warning] = 'The email for that account has not been verified. Please follow the instructions in the verification email we sent you.'
      redirect_to sign_in_url
    end
  end

  def set_variables
    @seo_title = 'LearnSignal - Sign In'
    @seo_description = "Sign In here to access LearnSignal's online courses"
  end

end
