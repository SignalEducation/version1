# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  subscription_plan_id :integer
#  stripe_guid          :string
#  next_renewal_date    :date
#  complimentary        :boolean          default(FALSE), not null
#  current_status       :string
#  created_at           :datetime
#  updated_at           :datetime
#  stripe_customer_id   :string
#  stripe_customer_data :text
#  livemode             :boolean          default(FALSE)
#  active               :boolean          default(FALSE)
#  terms_and_conditions :boolean          default(FALSE)
#

class SubscriptionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin individual_student customer_support_manager))
  end
  before_action :get_subscription
  before_action :check_subscriptions, only: [:new_subscription, :create_subscription]

  def change_plan
    @current_subscription = current_user.active_subscription
  end

  #Upgrading current sub to a new subscription plan
  def update
    if @subscription
      @subscription = @subscription.upgrade_plan(updatable_params[:subscription_plan_id].to_i)
      if @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscriptions.update.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong. @subscription.errors: #{@subscription.errors.inspect}."
        flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
      end
      redirect_to account_url(anchor: 'subscriptions')
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
    end
  end

  #Setting current sub to cancel at period end
  def destroy
    if @subscription
      if @subscription.cancel
        flash[:success] = I18n.t('controllers.subscriptions.destroy.flash.success')
      else
        Rails.logger.warn "WARN: Subscription#delete failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
        flash[:error] = I18n.t('controllers.subscriptions.destroy.flash.error')
      end
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    end

    if current_user.individual_student?
      redirect_to account_url(anchor: 'subscriptions')
    else
      redirect_to user_subscription_status_url(@subscription.user)
    end

  end

  def new_subscription
    @navbar = false
    @countries = Country.all_in_order
    @user = User.where(id: params[:user_id]).first
    @user.subscriptions.build
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : @user.country
    @currency_id = @country.currency_id
    @subscription_plans = SubscriptionPlan.includes(:currency).for_students.in_currency(@currency_id).generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid]).all_active.all_in_order
  end

  def create_subscription
    ####  User creating their first subscription  #####

    # Checks that all necessary params are present, then calls the upgrade_from_free_plan method in the Subscription Model
    if params[:user] && params[:user][:subscriptions_attributes] && params[:user][:subscriptions_attributes]["0"] && params[:user][:subscriptions_attributes]["0"]["subscription_plan_id"] && params[:user][:subscriptions_attributes]["0"]["stripe_token"]

      user = User.find(params[:user_id])
      subscription_params = params[:user][:subscriptions_attributes]["0"]
      subscription_plan = SubscriptionPlan.find(subscription_params["subscription_plan_id"].to_i)
      #Check for a coupon code and if its valid
      coupon_code = params[:coupon] unless params[:coupon].empty?
      verified_coupon = verify_coupon(coupon_code, user.country.currency_id) if coupon_code
      if coupon_code && verified_coupon == 'bad_coupon'
        #Invalid coupon code so redirect back with errors
        redirect_to user_new_subscription_url(current_user.id)
      else
        #No coupon code or a valid coupon code so proceed to create subscription on stripe
        stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        stripe_subscription = create_on_stripe(stripe_customer, subscription_plan, verified_coupon, subscription_params)
        stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        #Creation on stripe was successful so create our DB record of Subscription
        if stripe_customer && stripe_subscription
          subscription = Subscription.new(
              user_id: user.id,
              subscription_plan_id: subscription_plan.id,
              complimentary: false,
              active: true,
              livemode: stripe_subscription[:plan][:livemode],
              current_status: stripe_subscription.status,
          )
          # mass-assign-protected attributes
          subscription.stripe_guid = stripe_subscription.id
          subscription.next_renewal_date = Time.at(stripe_subscription.current_period_end)
          subscription.stripe_customer_id = stripe_customer.id
          subscription.terms_and_conditions = subscription_params["terms_and_conditions"]
          subscription.stripe_customer_data = stripe_customer.to_hash.deep_dup
          subscription_saved = subscription.save(validate: false)
        end

        if subscription_saved
          user.referred_signup.update_attribute(:payed_at, Proc.new{Time.now}.call) if current_user.referred_user
          if !user.free_trial_ended_at.nil?
            trial_ended_date = user.free_trial_ended_at
          else
            trial_ended_date = Proc.new{Time.now}.call
          end
          current_user.update_attributes(free_trial: false, free_trial_ended_at: trial_ended_date)
          redirect_to personal_upgrade_complete_url
        else
          redirect_to user_new_subscription_url(current_user.id)
          flash[:error] = "Your card was declined! Please check that it's valid and the details you entered are correct."
        end
      end
    else
      redirect_to user_new_subscription_url(current_user.id)
      flash[:error] = 'Sorry! Your request was declined. Please check that all details are valid and try again. Or contact us for assistance.'
    end

  end

  def create_on_stripe(stripe_customer, subscription_plan, verified_coupon, subscription_params)
    begin
      stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan.stripe_guid, coupon: verified_coupon, trial_end: 'now', source: subscription_params["stripe_token"])
      return stripe_subscription
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]
      puts "Status is: #{e.http_status}"
      puts "Type is: #{err[:type]}"
      puts "Code is: #{err[:code]}"
      # param is '' in this case
      puts "Param is: #{err[:param]}"
      puts "Message is: #{err[:message]}"
    rescue Stripe::RateLimitError => e
      # Too many requests made to the API too quickly
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
    rescue => e
      # Something else happened, completely unrelated to Stripe
    end
  end

  def personal_upgrade_complete
    @subscription = current_user.active_subscription
  end

  protected

  def updatable_params
    params.require(:subscription).permit(:subscription_plan_id)
  end

  def get_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end

  def check_subscriptions
    if current_user && current_user.valid_subscription
      redirect_to account_url(anchor: :subscriptions)
    elsif current_user && !current_user.individual_student?
      redirect_to root_url
    end
  end

end
