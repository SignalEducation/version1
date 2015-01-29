class UserActivityLogsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @user_activity_logs = UserActivityLog.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @user_activity_log = UserActivityLog.new
  end

  def edit
  end

  def create
    @user_activity_log = UserActivityLog.new(allowed_params)
    @user_activity_log.user_id = current_user.id
    if @user_activity_log.save
      flash[:success] = I18n.t('controllers.user_activity_logs.create.flash.success')
      redirect_to user_activity_logs_url
    else
      render action: :new
    end
  end

  def update
    if @user_activity_log.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.user_activity_logs.update.flash.success')
      redirect_to user_activity_logs_url
    else
      render action: :edit
    end
  end


  def destroy
    if @user_activity_log.destroy
      flash[:success] = I18n.t('controllers.user_activity_logs.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.user_activity_logs.destroy.flash.error')
    end
    redirect_to user_activity_logs_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @user_activity_log = UserActivityLog.where(id: params[:id]).first
    end
    @users = User.all_in_order
  end

  def allowed_params
    params.require(:user_activity_log).permit(:user_id, :session_guid, :signed_in, :original_uri, :controller_name, :action_name, :params, :ip_address, :alert_level, :browser, :operating_system, :phone, :tablet, :computer, :http_user_agent)
  end

end
