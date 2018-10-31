# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string
#  next_renewal_date        :date
#  complimentary            :boolean          default(FALSE), not null
#  current_status           :string
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string
#  stripe_customer_data     :text
#  livemode                 :boolean          default(FALSE)
#  active                   :boolean          default(FALSE)
#  terms_and_conditions     :boolean          default(FALSE)
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#

class SubscriptionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :get_subscription, except: [:new, :create]
  before_action :check_subscriptions, only: [:new, :create]

  def new
    @user = current_user
    if @user.trial_or_sub_user?

      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : @user.country

      # If user has previous subscription need to use that subs currency or stripe will reject sub in different currency
      @existing_subscription = @user.current_subscription
      if @existing_subscription && @existing_subscription.subscription_plan
        @currency_id = @existing_subscription.subscription_plan.currency_id
      else
        @currency_id = @country.currency_id
      end

      @subscription = Subscription.new(user_id: @user.id)

      @subscription_plans = SubscriptionPlan.includes(:currency).for_students.in_currency(@currency_id).generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid]).all_active.all_in_order

      IntercomUpgradePageLoadedEventWorker.perform_async(@user.id, @country.name) unless Rails.env.test?
    else
      redirect_to root_url
    end
  end

  def create
    @subscription = Subscription.new(subscription_params)

    subscription_service = SubscriptionService.new(@subscription)
    subscription_service.check_valid_subscription?(params)
    subscription_service.check_for_valid_coupon?(params[:hidden_coupon_code])
    @subscription = subscription_service.create_and_return_subscription(params)
    
    if @subscription.save
      if subscription_service.stripe?
        subscription_service.validate_referral
        redirect_to personal_upgrade_complete_url
      elsif subscription_service.paypal?
        redirect_to @subscription.paypal_approval_url
      end
    else
      Rails.logger.info "DEBUG: Subscription Failed to save for unknown reason - #{@subscription.inspect}"
      flash[:error] = 'Your request was declined. Please contact us for assistance!'
      redirect_to new_subscription_url
    end
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to request.referrer
  end

  def execute
    case params[:payment_processor]
    when 'paypal'
      if PaypalService.new.execute_billing_agreement(@subscription, params[:token])
        SubscriptionService.new(@subscription).validate_referral
        redirect_to personal_upgrade_complete_url
      else
        Rails.logger.error "DEBUG: Subscription Failed to save for unknown reason - #{@subscription.inspect}"
        flash[:error] = 'Your PayPal request was declined. Please contact us for assistance!'
        redirect_to new_subscription_url
      end
    else
      flash[:error] = 'Your payment request was declined. Please contact us for assistance!'
      redirect_to new_subscription_url
    end
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to new_subscription_url
  end

  def personal_upgrade_complete
    @subscription = current_user.current_subscription
  end

  def change_plan
    if current_user && current_user.current_subscription && !current_user.current_subscription.active_status?
      redirect_to account_url(anchor: :subscriptions)
    else
      @current_subscription = current_user.current_subscription
      @subscription_plans = @current_subscription.upgrade_options
    end
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
    if @subscription && @subscription.user.default_card
      @subscription = @subscription.upgrade_plan(updatable_params[:subscription_plan_id].to_i)
      if @subscription && @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscriptions.update.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong."
        flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
      end
      redirect_to account_url(anchor: 'subscriptions')
    else
      flash[:error] = I18n.t('controllers.subscriptions.update.flash.invalid_card')
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

  def subscription_params
    params.require(:subscription).permit(:user_id, :subscription_plan_id, :stripe_token, :terms_and_conditions, :hidden_coupon_code, :use_paypal)
  end

  def updatable_params
    params.require(:subscription).permit(:subscription_plan_id)
  end

  def get_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end

  def check_subscriptions
    if current_user && (current_user.valid_subscription? || current_user.canceled_pending?)
      redirect_to account_url(anchor: :subscriptions)
    elsif current_user && !current_user.trial_or_sub_user?
      redirect_to root_url
    end
  end

end
