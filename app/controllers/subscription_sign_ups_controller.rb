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
    time_now = Proc.new{Time.now}.call
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @currency_id = @country.currency_id
    @subscription_plans = SubscriptionPlan.includes(:currency).for_students.in_currency(@currency_id).generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid]).all_active.all_in_order.limit(3)

    @user = User.new(allowed_params)
    student_user_group = UserGroup.where(student_user: true, trial_or_sub_required: true).first
    @user.user_group_id = student_user_group.try(:id)
    @user.country_id = @country.id
    @user.account_activated_at = time_now
    @user.active = true
    @user.email_verified_at = time_now
    @user.email_verified = true

    subscription = @user.subscriptions.first
    coupon_code = params[:hidden_coupon_code]
    stripe_token = subscription.stripe_token
    subscription_plan_stripe_guid = subscription.subscription_plan.stripe_guid

    unless stripe_token && subscription_plan_stripe_guid
      flash[:error] = 'Sorry! The data entered is not valid. Please contact us for assistance.'
      redirect_to request.referrer and return
    end


    begin
      stripe_customer = Stripe::Customer.create(email: @user.email)
      stripe_subscription = Stripe::Subscription.create(
          customer: stripe_customer.id,
          plan: subscription_plan_stripe_guid,
          source: stripe_token,
          #coupon: @coupon.try(:code),
          trial_end: 'now'
      )

      @user.stripe_customer_id = stripe_customer.id


      subscription.assign_attributes(
          complimentary: false,
          active: true,
          livemode: stripe_subscription[:plan][:livemode],
          current_status: stripe_subscription.status,
          stripe_guid: stripe_subscription.id,
          next_renewal_date: Time.at(stripe_subscription.current_period_end),
          stripe_customer_id: stripe_customer.id,
          #coupon_id: @coupon.try(:id),
          stripe_customer_data: stripe_customer.to_hash.deep_dup
      )

      @user.build_student_access(trial_seconds_limit: ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i, trial_days_limit: ENV['FREE_TRIAL_DAYS'].to_i, account_type: 'Subscription', trial_started_date: time_now, trial_ended_date: time_now, content_access: true)

      if @user.save

        @user.update_attribute(:analytics_guid, cookies[:_ga]) if cookies[:_ga]
        @user.student_access.update_attribute(:subscription_id, @user.subscriptions.first.id)
        UserSession.create(@user)
        set_current_visit
        redirect_to new_subscription_sign_up_complete_url
      else
        render action: :new
      end




    rescue Stripe::CardError => e
      body = e.json_body
      err  = body[:error]

      Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"

      flash[:error] = "Sorry! Your request was declined because - #{err[:message]}"
      redirect_to request.referrer

    rescue => e
      Rails.logger.error "DEBUG: Subscription#create Failure for unknown reason - Error: #{e.inspect}"
      flash[:error] = 'Sorry Something went wrong! Please contact us for assistance.'
      redirect_to request.referrer
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
        :terms_and_conditions, subscriptions_attributes: [
        :subscription_plan_id, :stripe_token, :terms_and_conditions, :hidden_coupon_code]
    )
  end

  def check_logged_in_status
    redirect_to student_dashboard_url if current_user
  end

end
