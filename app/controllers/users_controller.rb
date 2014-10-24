class UsersController < ApplicationController

  before_action :logged_in_required
  before_action except: [:show, :edit, :update] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @users = User.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
    # profile page
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(allowed_params)
    if @user.save
      flash[:success] = I18n.t('controllers.users.create.flash.success')
      redirect_to users_url
    else
      render action: :new
    end
  end

  def update
    if @user.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      redirect_to users_url
    else
      render action: :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = I18n.t('controllers.users.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.users.destroy.flash.error')
    end
    redirect_to users_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      if current_user.admin?
        @user = User.where(id: params[:id]).first
      else
        @user = current_user
      end
    end
    # todo @countries = Country.all_in_order
    # todo @user_groups = UserGroup.all_in_order
  end

  def allowed_params
    if current_user.admin?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :corporate_customer_id, :corporate_customer_user_group_id, :operational_email_frequency, :study_plan_notifications_email_frequency, :falling_behind_email_alert_frequency, :marketing_email_frequency, :blog_notification_email_frequency, :forum_notification_email_frequency, :address, :country_id)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :operational_email_frequency, :study_plan_notifications_email_frequency, :falling_behind_email_alert_frequency, :marketing_email_frequency, :blog_notification_email_frequency, :forum_notification_email_frequency, :address, :country_id)
    end
  end

end
