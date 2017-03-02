class UserVerificationsController < ApplicationController

  def update

    @user = User.get_and_verify(params[:email_verification_code])
    if @user && @user.password_change_required?
      @user.update_attributes(password_reset_requested_at: Time.now, password_reset_token: SecureRandom.hex(10))
      set_password_url = set_password_url(id: @user.password_reset_token)
      redirect_to set_password_url
    elsif @user
      UserSession.create(@user)
      set_current_visit
      redirect_to account_verified_url
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
      redirect_to library_url
    end
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
      UserSession.create(@user)
      redirect_to library_url
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
      redirect_to library_url
    end

  end

end
