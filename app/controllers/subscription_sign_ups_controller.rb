class SubscriptionSignUpsController < ApplicationController

  before_action :check_logged_in_status


  def new
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @currency_id = @country.currency_id
    @subscription_plans = SubscriptionPlan.includes(:currency).for_students.in_currency(@currency_id).generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid]).all_active.all_in_order.limit(3)
    @user = User.new(country_id: @country.id)
    @user.subscriptions.build

  end


  def create
    @navbar = false
    @footer = false

    binding.pry
    @user = User.new(allowed_params)
    student_user_group = UserGroup.where(student_user: true, trial_or_sub_required: true).first
    @user.user_group_id = student_user_group.try(:id)
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id

    @user.build_student_access(trial_seconds_limit: ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i, trial_days_limit: ENV['FREE_TRIAL_DAYS'].to_i, account_type: 'Subscription')



    if @user.valid? && @user.save
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(
          email: @user.try(:email)
      )


      @user.update_attribute(:stripe_customer_id, stripe_customer.id)
      @user.update_attribute(:analytics_guid, cookies[:_ga]) if cookies[:_ga]
      @user.student_access.update_attribute(:subscription_id, @subscription.id)


      redirect_to new_subscription_sign_up_complete_url
    else
      render action: :new
    end
  end

  def show
    #This is the post sign-up landing page

  end




  protected

  def allowed_params
    params.require(:user).permit(
        :email, :first_name, :last_name,
        :country_id, :locale,
        :password, :password_confirmation,
        :terms_and_conditions, subscription: [
        :subscription_plan_id, :stripe_token, :terms_and_conditions, :hidden_coupon_code]
    )
  end

  def check_logged_in_status
    redirect_to student_dashboard_url if current_user
  end

end
