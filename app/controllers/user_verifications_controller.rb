class UserVerificationsController < ApplicationController

  def update
    @user = User.get_and_verify(params[:email_verification_code])
    if @user && @user.password_change_required?

      @user.update_attributes(password_reset_requested_at: Time.now,
                              password_reset_token: SecureRandom.hex(10))
      reset_password_url = reset_password_url(id: @user.password_reset_token)
      redirect_to reset_password_url
    end
    if @user
      UserSession.create(@user)
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
    end
    redirect_to library_url
  end

  def old_mail_activation
    @user = User.get_and_verify(params[:email_verification_code])
    if @user && @user.password_change_required?
      @user.update_attributes(password_reset_requested_at: Time.now,
                              password_reset_token: SecureRandom.hex(10),
                              account_activated_at: Time.now,
                              account_activation_code: nil,
                              active: true
      )
      reset_password_url = reset_password_url(id: @user.password_reset_token)
      redirect_to reset_password_url
    elsif @user
      @user.update_attributes(account_activated_at: Time.now,
                              account_activation_code: nil,
                              active: true)
    end

    if @user
      UserSession.create(@user)
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
    end
    redirect_to library_url
  end


end
