class UserSessionsController < ApplicationController

  before_action :logged_out_required, only: [:new, :create]
  before_action :logged_in_required,  only: :destroy
  before_action :set_variables
  before_action :check_user_group, only: [:create]

  def new
    @user_session = UserSession.new
    seo_title_maker('Log in to Start Studying Today | LearnSignal',
                    "Log in to your ACCA or CPD courses to access topic-by-topic tuition modules, explore online learning resources and kick-start your study today.",
                    false)
    render 'user_sessions/new'
  end

  def create
    @user_session = UserSession.new(user_session_params.to_h)
    if @user_session.save
      @user_session.user.update_attribute(:session_key, session[:session_id])
      @user_session.user.update_attribute(:analytics_guid, cookies[:_ga]) if cookies[:_ga]
      @user_session.user.update_attributes(password_reset_token: nil, password_reset_requested_at: nil) if @user_session.user.password_reset_token
      set_current_visit
      flash[:error] = nil
      if flash[:plan_guid]
        redirect_to new_subscription_url(plan_guid: flash[:plan_guid], exam_body_id: flash[:exam_body])
      elsif session[:return_to]
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

  def user_session_params
    params.require(:user_session).permit(:email, :password)
  end

  def check_user_group
    user = User.find_by_email(params[:user_session][:email])
    if user && user.blocked_user?
      flash[:error] = 'Sorry. That account is blocked. Please contact us for assistance.'
      redirect_to sign_in_url
    end
  end

  def set_variables
  end

end
