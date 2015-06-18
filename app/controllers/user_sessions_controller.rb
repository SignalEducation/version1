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
      flash[:success] = I18n.t('controllers.user_sessions.create.flash.success')
      redirect_back_or_default root_url
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
    @seo_title = 'LearnSignal – Sign In'
  end

end
