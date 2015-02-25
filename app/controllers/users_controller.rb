class UsersController < ApplicationController

  before_action :logged_in_required
  before_action except: [:show, :edit, :update, :change_password] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @users = User.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
    # profile page
    if params[:update].to_s.length > 0
      case params[:update]
        when 'invoices'
          Invoice.get_updates_for_user(@user.stripe_customer_id)
        when 'cards'
          SubscriptionPaymentCard.get_updates_for_user(@user.stripe_customer_id)
        when 'subscriptions'
          # todo
          ####################################################
        else
          # do nothing
      end
      @user.reload
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(allowed_params)
    @user.locale = 'en'
    if @user.save
      Mailers::OperationalMailers::ActivateAccountWorker.perform_async(@user.id)
      flash[:success] = I18n.t('controllers.users.create.flash.success')
      redirect_to users_url
    else
      render action: :new
    end
  end

  def update
    if @user.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      if current_user.admin?
        redirect_to users_url
      else
        redirect_to profile_url
      end
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

  # non-standard methods

  def change_password
    @user = current_user
    if @user.change_the_password(change_password_params)
      flash[:success] = I18n.t('controllers.users.change_password.flash.success')
      Mailers::OperationalMailers::YourPasswordHasChangedWorker.perform_async(@user.id)
    else
      flash[:error] = I18n.t('controllers.users.change_password.flash.error')
    end
    if current_user.admin?
      redirect_to users_url
    else
      redirect_to profile_url
    end
  end

  protected

  def get_variables
    @user = params[:id].to_i > 0 && current_user.admin? ?
                  @user = User.where(id: params[:id]).first :
                  current_user
    @email_frequencies = User::EMAIL_FREQUENCIES
    @countries = Country.all_in_order
    @user_groups = UserGroup.all_in_order
    seo_title_maker(@user.try(:full_name))
  end

  def allowed_params
    if current_user.admin?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :corporate_customer_id, :corporate_customer_user_group_id, :operational_email_frequency, :study_plan_notifications_email_frequency, :falling_behind_email_alert_frequency, :marketing_email_frequency, :blog_notification_email_frequency, :forum_notification_email_frequency, :address, :country_id, :password, :password_confirmation)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :operational_email_frequency, :study_plan_notifications_email_frequency, :falling_behind_email_alert_frequency, :marketing_email_frequency, :blog_notification_email_frequency, :forum_notification_email_frequency, :address, :country_id, :password, :password_confirmation)
    end
  end

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

end
