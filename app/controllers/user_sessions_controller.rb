class UserSessionsController < ApplicationController

  before_filter :logged_out_required, only: [:new, :create]
  before_filter :logged_in_required,  only: :destroy
  before_filter :set_variables

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      assign_anonymous_logs_to_user
      flash[:success] = I18n.t('controllers.user_sessions.create.flash.success')
      redirect_back_or_default root_url
    else
      render action: :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:success] = I18n.t('controllers.user_sessions.destroy.flash.success')
    redirect_to root_url
  end

  protected

  def assign_anonymous_logs_to_user
    model_list = [CourseModuleElementUserLog, UserActivityLog, StudentExamTrack]
    model_list.each do |the_model|
      the_model.assign_user_to_session_guid(@user_session.user.id, current_session_guid)
    end
  end

  def set_variables
    @seo_title = 'LearnSignal – Sign In'
  end

end
