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
        @user_session = UserSession.create!(@user)
        set_current_visit
        flash[:success] = I18n.t('controllers.user_password_resets.update.flash.success')
        @user.update_attribute(:password_change_required, nil)
        redirect_back_or_default root_url
      else
        #TODO need to improve if/else statements here. If @user can't be found then pw reset process needs to start again with new email submission and email with reset link. But currently could not work due to account being set to active after first part of reset process.

        @user = User.find_by_password_reset_token(params[:id])
        if @user
          flash[:error] = I18n.t('controllers.user_password_resets.update.flash.error')
          render :edit
        else
          redirect_to root_url
          flash[:error] = I18n.t('controllers.user_password_resets.update.flash.user_error')
        end
      end
    else
      @user = User.find_by_password_reset_token(params[:id])
      if @user
        flash[:error] = I18n.t('controllers.user_password_resets.update.flash.password_and_confirmation_do_not_match')
        render :edit
      else
        redirect_to root_url
        flash[:error] = I18n.t('controllers.user_password_resets.update.flash.user_error')
      end
    end
  end

  #Admin invite allow user to input password
  def set_password
    if params[:id].to_s.length == 20
      @user = User.where(password_reset_token: params[:id].to_s).first
      if @user
        render :set_password
      else
        flash[:error] = I18n.t('controllers.user_password_resets.edit.flash.error')
        redirect_to root_url
      end
    else
      flash[:error] = I18n.t('controllers.user_password_resets.edit.flash.error')
      redirect_to root_url
    end
    seo_title_maker('Set password for your account', 'Please enter a valid password to finish setting up your account.', true)
  end

  #Admin invite update user to set the password
  def create_password
    if params[:password] == params[:password_confirmation]
      # in the params, params[:id] holds the reset_token.
      @user = User.finish_password_reset_process(params[:id], params[:password], params[:password_confirmation])
      if @user
        @user_session = UserSession.create(@user)
        flash[:success] = I18n.t('controllers.user_password_resets.update.flash.success')
        @user.update_attributes(password_change_required: nil, session_key: session[:session_id])
        redirect_back_or_default library_url
      else
        @user = User.find_by_password_reset_token(params[:id])
        flash[:error] = I18n.t('controllers.user_password_resets.update.flash.error')
        render :set_password
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
