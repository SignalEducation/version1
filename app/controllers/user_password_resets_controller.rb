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
    if params[:password] == params[:password_confirmation]
      # in the params, params[:id] holds the reset_token.
      @user = User.finish_password_reset_process(params[:id], params[:password], params[:password_confirmation])
      if @user
        UserSession.create!(@user)
        flash[:success] = I18n.t('controllers.user_password_resets.update.flash.success')
        Mailers::OperationalMailers::YourPasswordHasChangedWorker.perform_async(@user.id) unless @user.password_change_required
        @user.update_attribute(:password_change_required, nil)
        redirect_to root_url
      else
        @user = User.find_by_password_reset_token(params[:id])
        flash[:error] = I18n.t('controllers.user_password_resets.update.flash.error')
        render :edit
      end
    else
      @user = User.find_by_password_reset_token(params[:id])
      redirect_to root_url if @user.nil?

      flash[:error] = I18n.t('controllers.user_password_resets.update.flash.password_and_confirmation_do_not_match')
      render :edit
    end
  end

  protected

  def get_variables
    seo_title_maker('Reset your password', 'Forgot password? No problem! Enter your email address and we will send you further instructions.', true)
  end
end
