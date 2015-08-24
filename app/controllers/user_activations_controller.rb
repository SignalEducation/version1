class UserActivationsController < ApplicationController

  before_action :logged_out_required
  before_action :check_if_password_change_is_required

  def update # responds to 'get'
    if @user
      UserSession.create(@user)
      @user.assign_anonymous_logs_to_user(current_session_guid)
      flash[:success] = I18n.t('controllers.user_activations.update.success')
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
    end
    redirect_to library_url
  end

  private
  def check_if_password_change_is_required
    @user = User.get_and_activate(params[:activation_code])
    if @user && @user.password_change_required?
      @user.update_attributes(password_reset_requested_at: Time.now,
                              password_reset_token: SecureRandom.hex(10),
                              active: false)
      reset_password_url = reset_password_url(id: @user.password_reset_token)
      redirect_to reset_password_url
    end
  end

end
