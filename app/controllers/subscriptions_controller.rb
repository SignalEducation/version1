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
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :get_subscription
  before_action :check_subscriptions, only: [:new_subscription, :create_subscription]

  def new_subscription
    @navbar = false
    @top_margin = false
    @countries = Country.all_in_order
    @user = User.where(id: params[:user_id]).first
    if current_user.id == @user.id
      @user.subscriptions.build
      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : @user.country
      @currency_id = @country.currency_id
      @subscription_plans = SubscriptionPlan.includes(:currency).for_students.in_currency(@currency_id).generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid]).all_active.all_in_order
      IntercomUpgradePageLoadedEventWorker.perform_async(@user.id, @country.name) unless Rails.env.test?
    else
      redirect_to root_url
    end
  end

  def create_subscription
    #TODO Reconfigure to use allowed_params
    user = User.find(params[:user_id])
    subscription_params = params[:user][:subscriptions_attributes]["0"]
    subscription_plan = SubscriptionPlan.find(subscription_params["subscription_plan_id"].to_i)

    if user && user.id == current_user.id && subscription_params && subscription_plan && subscription_params["terms_and_conditions"] && subscription_params["terms_and_conditions"] == 'true'

      # Coupon Code Param Check
      if params["hidden_coupon_code"] && params["hidden_coupon_code"].present?
        # Coupon Code Verification
        verified_coupon = verify_coupon(params["hidden_coupon_code"], subscription_plan.currency_id)

        if verified_coupon == 'bad_coupon'
          redirect_to user_new_subscription_url(current_user.id, coupon: true)
          return
        else
          stripe_subscription = create_on_stripe(user.stripe_customer_id, subscription_plan, subscription_params, verified_coupon)
        end
      else
        stripe_subscription = create_on_stripe(user.stripe_customer_id, subscription_plan, subscription_params, nil)
      end

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
        trial_ended_date = user.student_access.trial_ended_date ? user.student_access.trial_ended_date : Proc.new{Time.now}.call
        user.student_access.update_attributes(subscription_id: subscription_saved.id, trial_ended_date: trial_ended_date, account_type: 'Subscription', content_access: true)

        user.referred_signup.update_attribute(:payed_at, Proc.new{Time.now}.call) if user.referred_user
        redirect_to personal_upgrade_complete_url
      else
        redirect_to user_new_subscription_url(current_user.id)
        flash[:error] = "Your card was declined! Please check that it's valid and the details you entered are correct."
      end

    else
      redirect_to user_new_subscription_url(current_user.id)
      flash[:error] = 'Sorry! Your request was declined. Please check that all details are valid and try again. Or contact us for assistance.'
    end

  end

  def personal_upgrade_complete
    @subscription = current_user.current_subscription
  end

  def change_plan
    @current_subscription = current_user.current_subscription
    @subscription_plans = @current_subscription.upgrade_options
  end

  def un_cancel_subscription
    if @subscription && @subscription.current_status == 'canceled-pending'
      @subscription.un_cancel

      if @subscription && @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscriptions.un_cancel.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionsController#un_cancel_subscription - something went wrong."
        flash[:error] = I18n.t('controllers.subscriptions.un_cancel.flash.error')
      end
      redirect_to account_url(anchor: 'subscriptions')
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to account_url(anchor: 'subscriptions')
    end
  end

  #Upgrading current subscription to a new subscription plan
  def update
    if @subscription
      @subscription = @subscription.upgrade_plan(updatable_params[:subscription_plan_id].to_i)
      if @subscription && @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscriptions.update.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong."
        flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
      end
      redirect_to account_url(anchor: 'subscriptions')
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
    end
  end

  #Setting current subscription to cancel-pending or canceled. We don't actually delete the Subscription Record
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

    if current_user.trial_or_sub_user?
      redirect_to account_url(anchor: 'subscriptions')
    else
      redirect_to user_subscription_status_url(@subscription.user)
    end
  end

  def create_on_stripe(stripe_customer_id, subscription_plan, subscription_params, coupon_code)
    begin
      stripe_subscription = Stripe::Subscription.create(
          customer: stripe_customer_id,
          plan: subscription_plan.stripe_guid,
          source: subscription_params["stripe_token"],
          coupon: coupon_code,
          trial_end: 'now'
      )

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
    elsif current_user && !current_user.trial_or_sub_user?
      redirect_to root_url
    end
  end

end
