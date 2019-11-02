# frozen_string_literal: true

class UserPasswordsController < ApplicationController
  before_action :logged_out_required, except: [:manager_resend_email]
  before_action :get_variables

  def new
    seo_title_maker('Forgot Your LearnSignal Password | LearnSignal',
                    'Forgot your learnsignal password? No problem! Enter your email address to reset your password and access your online learning materials today.',
                    nil)
  end

  def create
    User.start_password_reset_process(params[:email_address].to_s, root_url)
    seo_title_maker('Password Reset Email Sent | LearnSignal',
                    "Check your mailbox for further instructions. If you don't receive an email from learnsignal within a couple of minutes, check your spam folder.",
                    nil)
  end

  def manager_resend_email
    user = User.resend_pw_reset_email(params[:id], root_url)
    redirect_to user_url(user.id)
  end

  def edit
    seo_title_maker('Reset Your Password | LearnSignal',
                    'Enter a new password for your learnsignal subscription account here to access your online learning materials and start studying today.',
                    nil)

    if params[:id].to_s.length == 20
      @user = User.where(password_reset_token: params[:id].to_s).first
      if @user
        if @user.email_verified
          render :edit
        else
          flash[:error] = I18n.t('controllers.user_passwords.edit.flash.error')
          redirect_to sign_in_url
        end
      else
        flash[:warning] = I18n.t('controllers.user_passwords.edit.flash.warning')
        redirect_to sign_in_url
      end
    else
      flash[:warning] = I18n.t('controllers.user_passwords.edit.flash.warning')
      redirect_to sign_in_url
    end
  end

  def update
    if params[:password] == params[:password_confirmation]
      # in the params, params[:id] holds the reset_token.
      @user = User.finish_password_reset_process(params[:id], params[:password], params[:password_confirmation])
      if @user
        @user_session = UserSession.create!(@user)
        set_current_visit(@user_session.user)
        flash[:success] = I18n.t('controllers.user_passwords.update.flash.success')
        @user.update_attribute(:password_change_required, nil)
        redirect_back_or_default root_url
      else
        # TODO, need to improve if/else statements here.
        # If @user can't be found then pw reset process needs to start again with
        # new email submission and email with reset link. But currently could not
        # work due to account being set to active after first part of reset process.

        @user = User.find_by(password_reset_token: params[:id])
        if @user
          flash[:error] = I18n.t('controllers.user_passwords.update.flash.error')
          render :edit
        else
          redirect_to root_url
          flash[:error] = I18n.t('controllers.user_passwords.update.flash.user_error')
        end
      end
    else
      @user = User.find_by(password_reset_token: params[:id])
      if @user
        flash[:error] = I18n.t('controllers.user_passwords.update.flash.password_and_confirmation_do_not_match')
        render :edit
      else
        redirect_to root_url
        flash[:error] = I18n.t('controllers.user_passwords.update.flash.user_error')
      end
    end
  end

  def set_password
    if params[:id].to_s.length == 20
      @user = User.find_by(password_reset_token: params[:id].to_s)

      if @user
        render :set_password
      else
        flash[:error] = I18n.t('controllers.user_passwords.edit.flash.error')
        redirect_to root_url
      end
    else
      flash[:error] = I18n.t('controllers.user_passwords.edit.flash.error')
      redirect_to root_url
    end
    seo_title_maker('Set password for your account', 'Please enter a valid password to finish setting up your account.', true)
  end

  def create_password
    time_now = params[:hidden][:communication_approval] ? Proc.new{ Time.now }.call : nil

    if params[:password] == params[:password_confirmation]
      # in the params, params[:id] holds the reset_token.
      @user = User.finish_password_reset_process(params[:id], params[:password], params[:password_confirmation])
      if @user
        @user_session = UserSession.create(@user)
        flash[:success] = I18n.t('controllers.user_passwords.update.flash.success')
        @user.update_attributes(password_change_required: nil, session_key: session[:session_id],
                                terms_and_conditions: params[:hidden][:terms_and_conditions],
                                communication_approval: params[:hidden][:communication_approval],
                                communication_approval_datetime: time_now)
        redirect_back_or_default library_url
      else
        @user = User.find_by(password_reset_token: params[:id])
        flash[:error] = I18n.t('controllers.user_passwords.update.flash.error')
        if @user
          render :set_password
        else
          redirect_to root_url
        end
      end
    else
      @user = User.find_by(password_reset_token: params[:id])
      flash[:error] = I18n.t('controllers.user_passwords.update.flash.password_and_confirmation_do_not_match')
      if @user
        render :edit
      else
        redirect_to root_url
      end
    end
  end

  protected

  def get_variables
    seo_title_maker('Reset your password', 'Forgot password? No problem! Enter your email address and we will send you further instructions.', true)
  end
end
