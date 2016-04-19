class UserSessionsController < ApplicationController

  before_filter :logged_out_required, only: [:new, :create]
  before_filter :logged_in_required,  only: :destroy
  before_filter :set_variables

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(allowed_params)
    if @user_session.save
      @user_session.user.assign_anonymous_logs_to_user(current_session_guid)
      @user_session.user.update_attribute(:session_key, session[:session_id])
      flash[:error] = nil
      if @user_session.user.corporate_customer?
        redirect_to corporate_customer_url(@user_session.user.corporate_customer)
      elsif @user_session.user.corporate_student?
        redirect_to library_url
      elsif session[:return_to]
        redirect_to library_url
      else
        redirect_to library_url, flash: { just_signed_in: true }
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

  def set_variables
    @seo_title = 'LearnSignal - Sign In'
    @seo_description = "Sign In here to access LearnSignal's online courses"
  end

end
