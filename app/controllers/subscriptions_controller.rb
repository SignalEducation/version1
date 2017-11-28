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
  before_action :check_subscriptions, only: [:new, :create]

  def new
    @user = current_user
    if @user.trial_or_sub_user?
      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : @user.country
      @currency_id = @country.currency_id

      @subscription = Subscription.new(user_id: @user.id)

      @subscription_plans = SubscriptionPlan.includes(:currency).for_students.in_currency(@currency_id).generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid]).all_active.all_in_order
      IntercomUpgradePageLoadedEventWorker.perform_async(@user.id, @country.name) unless Rails.env.test?
    else
      redirect_to root_url
    end
  end

  def create
    @subscription = Subscription.new(allowed_params)
    stripe_token = params[:subscription][:stripe_token]
    user = @subscription.user
    subscription_plan_stripe_guid = @subscription.subscription_plan.stripe_guid
    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
    
    begin
      stripe_subscription = Stripe::Subscription.create(
          customer: user.stripe_customer_id,
          plan: subscription_plan_stripe_guid,
          source: stripe_token,
          trial_end: 'now'
      )

      @subscription.assign_attributes(
          complimentary: false,
          active: true,
          livemode: stripe_subscription[:plan][:livemode],
          current_status: stripe_subscription.status,
          stripe_guid: stripe_subscription.id,
          next_renewal_date: Time.at(stripe_subscription.current_period_end),
          stripe_customer_id: stripe_customer.id,
          stripe_customer_data: stripe_customer.to_hash.deep_dup
      )
      if @subscription.valid? && @subscription.save
        trial_ended_date = user.student_access.trial_ended_date ? user.student_access.trial_ended_date : Proc.new{Time.now}.call
        user.student_access.update_attributes(subscription_id: @subscription.id, trial_ended_date: trial_ended_date, account_type: 'Subscription', content_access: true)

        user.referred_signup.update_attribute(:payed_at, Proc.new{Time.now}.call) if user.referred_user
        redirect_to personal_upgrade_complete_url
      else
        Rails.logger.error "DEBUG: Subscription Failed to save for unknown reason - #{@subscription.inspect}"
        flash[:error] = 'Your request was declined. Please contact us for assistance!'
        redirect_to new_subscription_url
      end


    rescue Stripe::CardError => e
      body = e.json_body
      err  = body[:error]

      Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"

      flash[:error] = "Sorry! Your request was declined because - #{err[:message]}"
      redirect_to new_subscription_url

    rescue => e
      Rails.logger.error "DEBUG: Subscription#create Failure for unknown reason - Error: #{e.inspect}"
      flash[:error] = 'Sorry Something went wrong! Please contact us for assistance.'
      redirect_to new_subscription_url
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

  protected

  def allowed_params
    params.require(:subscription).permit(:user_id, :subscription_plan_id, :stripe_token, :terms_and_conditions, :hidden_coupon_code)
  end

  def updatable_params
    params.require(:subscription).permit(:subscription_plan_id)
  end

  def get_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end

  def check_subscriptions
    if current_user && current_user.valid_subscription?
      redirect_to account_url(anchor: :subscriptions)
    elsif current_user && !current_user.trial_or_sub_user?
      redirect_to root_url
    end
  end

end
