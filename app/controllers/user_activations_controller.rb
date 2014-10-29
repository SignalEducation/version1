class UserActivationsController < ApplicationController

  before_action :logged_out_required

  def update # responds to 'get'
    # find the user whose activation code matches params[:activation_code]
    @user = User.find_and_activate(params[:activation_code])
    # if found, log the user in
    if @user
      UserSession.create(@user)
      flash[:success] = I18n.t('controllers.user_activations.update.success')
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
    end
    redirect_to root_url # dashboard_url todo
  end

end
