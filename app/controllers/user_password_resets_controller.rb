class UserPasswordResetsController < ApplicationController

  before_action :logged_out_required
  before_action :get_variables

  def new
  end

  def create
    User.start_password_reset_process(params[:email_address].to_s, root_url)
  end

  def edit
    if params[:id].to_s.length == 20
      @user = User.where(password_reset_token: params[:id].to_s, active: false).first
      if @user
        render :edit
      else
        flash[:error] = I18n.t('controllers.user_password_resets.edit.flash.error')
        redirect_to root_url
      end
    else
      flash[:error] = I18n.t('controllers.user_password_resets.edit.flash.error')
      redirect_to root_url
    end
  end

  def update
    # in the params, params[:id] holds the reset_token.
    @user = User.finish_password_reset_process(params[:id], params[:password], params[:password_confirmation])
    if @user
      UserSession.create!(@user)
      flash[:success] = I18n.t('controllers.user_password_resets.update.flash.success')
      Mailers::OperationalMailers::YourPasswordHasChangedWorker.perform_async(@user.id)
    else
      flash[:error] = I18n.t('controllers.user_password_resets.update.flash.error')
    end
    redirect_to root_url
  end

  protected

  def get_variables
    seo_title_maker('Reset your password', '', true)
  end
end
