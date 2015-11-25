class UsersController < ApplicationController

  before_action :logged_in_required, except: [:profile, :profile_index]
  before_action except: [:show, :edit, :update, :change_password, :new_paid_subscription, :upgrade_from_free_trial, :profile, :profile_index] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables, except: [:profile, :profile_index]

  def index
    @users = params[:search_term].to_s.blank? ?
             @users = User.paginate(per_page: 50, page: params[:page]) :
             @users = User.search_for(params[:search_term].to_s).
                     paginate(per_page: 50, page: params[:page])
    @users = params[:sort_by].to_s.blank? ?
             @users.all_in_order :
             @users = @users.sort_by(params[:sort_by].to_s)
    @sort_choices = User::SORT_OPTIONS.map { |x| [x.humanize.camelcase, x] }
  end

  def show
    # account page
    if params[:update].to_s.length > 0
      case params[:update]
        when 'invoices'
          Invoice.get_updates_for_user(@user.stripe_customer_id)
        when 'cards'
          SubscriptionPaymentCard.get_updates_for_user(@user.stripe_customer_id)
        when 'subscriptions'
          Rails.logger.debug 'DEBUG: start a call to Subscription#get_updates_for_user'
          Subscription.get_updates_for_user(@user.stripe_customer_id)
        else
          # do nothing
      end
      @user.reload
    end
    if current_user.corporate_customer?
      @corporate_customer = current_user.corporate_customer
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    if Rails.env.production?
      password = SecureRandom.hex(5)
    else
      password = '123123123'
    end
    @user = User.new(allowed_params.merge({password: password,
                                           password_confirmation: password,
                                           password_change_required: true}))
    @user.de_activate_user
    @user.locale = 'en'
    if @user.user_group.try(:site_admin) == false && @user.save
      MandrillWorker.perform_async(@user.id,
                                   'send_verification_email',
                                   user_activation_url(activation_code: @user.account_activation_code))
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
        redirect_to account_url
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
      redirect_to account_url
    end
  end

  def new_paid_subscription
    redirect_to account_url if current_user.subscriptions.count > 1
    @user = current_user
    if current_user.subscriptions.first.subscription_plan == SubscriptionPlan.where(id: 51).first
      @subscription_plans = SubscriptionPlan
                                .where('price > 0.0')
                                .for_students
                                .in_currency(1)
                                .generally_available
                                .all_active
                                .all_in_order
    else
      @subscription_plans = SubscriptionPlan
                            .where('price > 0.0')
                            .includes(:currency)
                            .for_students
                            .in_currency(current_user.subscriptions.first.subscription_plan.currency_id)
                            .generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid])
                            .all_active
                            .all_in_order
    end
  end

  def profile
    #/profile/id
    @tutor = User.all_tutors.where(id: params[:id]).first
    if @tutor
      @courses = SubjectCourse.where(tutor_id: @tutor.id)
    else
      redirect_to root_url
    end
  end

  def profile_index
    #/profiles
    @tutors = User.all_tutors.where.not(profile_image_file_name: nil)
  end

  def upgrade_from_free_trial
    if current_user.subscriptions.count == 1 && current_user.subscriptions[0].free_trial? &&
       params[:user] && params[:user][:subscriptions_attributes] && params[:user][:subscriptions_attributes]["0"]
      current_user.subscriptions[0].cancel
      subscription_params = params[:user][:subscriptions_attributes]["0"]
      current_user.subscriptions.create(subscription_plan_id: subscription_params["subscription_plan_id"],
                                        stripe_token: subscription_params["stripe_token"])
      redirect_to dashboard_url
    else
      redirect_to account_url
    end
  end

  protected

  def get_variables
    @user = params[:id].to_i > 0 && current_user.admin? ?
                  @user = User.where(id: params[:id]).first :
                  current_user
    @email_frequencies = User::EMAIL_FREQUENCIES
    @countries = Country.all_in_order
    if (action_name == 'show' || action_name == 'edit' || action_name == 'update') && @user.admin?
      @user_groups = UserGroup.all_in_order
    else
      @user_groups = UserGroup.where(site_admin: false).all_in_order
    end
      seo_title_maker(@user.try(:full_name), '', true)
      @current_subscription = @user.subscriptions.all_in_order.last
      @corporate_customers = CorporateCustomer.all_in_order
  end

  def allowed_params
    if current_user.admin?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :corporate_customer_id, :operational_email_frequency, :study_plan_notifications_email_frequency, :falling_behind_email_alert_frequency, :marketing_email_frequency, :blog_notification_email_frequency, :forum_notification_email_frequency, :address, :country_id, :first_description, :second_description, :wistia_url, :personal_url, :name_url, :qualifications, :profile_image)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :operational_email_frequency, :study_plan_notifications_email_frequency, :falling_behind_email_alert_frequency, :marketing_email_frequency, :blog_notification_email_frequency, :forum_notification_email_frequency, :address, :country_id, :employee_guid, :first_description, :second_description, :wistia_url, :personal_url, :qualifications, :profile_image, :phone_number)
    end
  end

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

end
