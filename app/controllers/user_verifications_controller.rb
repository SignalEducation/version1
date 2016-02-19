class UserVerificationsController < ApplicationController

  before_action :check_if_password_change_is_required

  def update # responds to 'get'
    if @user
      @user = User.get_and_verify(params[:email_verification_code])
      UserSession.create(@user)
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
    end
    redirect_to library_url
  end

  private
  def check_if_password_change_is_required
    if @user && @user.password_change_required?
      @user = User.get_and_activate(params[:activation_code])
      @user.update_attributes(password_reset_requested_at: Time.now,
                              password_reset_token: SecureRandom.hex(10),
                              active: false)
      reset_password_url = reset_password_url(id: @user.password_reset_token)
      redirect_to reset_password_url
    end
  end

end
