# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  include Subscriptions::Support # concern/subscriptions/support.rb

  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[student_user]) }
  before_action :set_subscription, except: %i[new create personal_upgrade_complete]
  before_action :set_flash, :redirects_conditions, only: :new

  def show
    redirect_to dashboard_path unless @subscription.user_id == current_user.id
  end

  def new
    @plans        = get_relevant_subscription_plans
    @yearly_plan  = @plans.yearly.first
    @subscription = Subscription.includes(:exam_body).
                      new(user_id: current_user.id, subscription_plan_id: filtered_plan.id,
                          completion_guid: ApplicationController.generate_random_code(20))

    seo_title_maker('Course Membership Payment | LearnSignal', 'Pay monthly, quarterly or yearly for learnsignal and access professional course materials, expert notes and corrected questions anytime, anywhere.', false)
  end

  def create
    @subscription        = Subscription.new(subscription_params)
    subscription_service = SubscriptionService.new(@subscription)
    subscription_service.check_valid_subscription?(params)
    subscription_service.check_for_valid_coupon?(params[:hidden_coupon_code])

    # call private stripe_subscription or paypal_subscription method
    send("#{params['payment-options']}_subscription",
         @subscription, subscription_service, params)
  rescue Learnsignal::SubscriptionError => e
    if request.xhr?
      render json: { subscription_id: @subscription.id,
                     error: e.message }, status: :error
    else
      flash[:error] = e.message
      redirect_to new_subscription_url(subscription_plan_id: params[:subscription][:subscription_plan_id])
    end
  end

  def execute
    case params[:payment_processor]
    when 'paypal'
      if PaypalSubscriptionsService.new(@subscription).execute_billing_agreement(params[:token])
        @subscription.start!
        SubscriptionService.new(@subscription).validate_referral
        if @subscription.changed_from_id
          redirect_to subscriptions_plan_change_url, notice: 'Your new plan is confirmed!'
        else
          redirect_to personal_upgrade_complete_url(@subscription.completion_guid)
        end
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
    @subscription = current_user.subscriptions.find_by(completion_guid: params[:completion_guid]) if params[:completion_guid]
    redirect_to account_url(anchor: 'account-info') and return unless @subscription
    @subscription.update(completion_guid: nil)
    Rails.logger.info "DataLayer Event: Subscription#personal_upgrade_complete - Subscription: #{@subscription.id} with completion_guid #{params[:completion_guid]}, Revenue: #{@subscription.subscription_plan.price}, PlanName: #{@subscription.subscription_plan.name}, Brand: #{@subscription.subscription_plan.exam_body.name}"
    seo_title_maker('Thank You for Subscribing | LearnSignal',
                    'Thank you for subscribing to learnsignal you can now access professional course materials, expert notes and corrected questions anytime, anywhere.',
                    false)
  end

  def un_cancel
    if @subscription&.stripe_status == 'canceled-pending'
      @subscription.un_cancel

      if @subscription&.errors&.count&.zero?
        flash[:success] = I18n.t('controllers.subscriptions.un_cancel.flash.success')
      else
        Rails.logger.error 'ERROR: SubscriptionsController#un_cancel - something went wrong.'
        flash[:error] = I18n.t('controllers.subscriptions.un_cancel.flash.error')
      end
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    end

    redirect_to account_url(anchor: 'account-info')
  end

  # Setting current subscription to cancel-pending or canceled. We don't actually delete the Subscription Record
  def destroy
    if @subscription
      if @subscription.cancel_by_user
        flash[:success] = I18n.t('controllers.subscriptions.destroy.flash.success')
      else
        Rails.logger.warn "WARN: Subscription#delete failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
        flash[:error] = I18n.t('controllers.subscriptions.destroy.flash.error')
      end
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    end

    if current_user.standard_student_user?
      redirect_to account_url(anchor: 'account-info')
    else
      redirect_to user_subscription_status_url(@subscription.user)
    end
  end

  def status_from_stripe
    update_status(params[:status])

    flash[:notice] = 'Your subscription is confirmed!'
  end

  private

  def stripe_subscription(subscription, subscription_service, params)
    token               = params[:subscription][:stripe_token]
    coupon              = subscription_service.coupon
    @subscription, data = StripeSubscriptionService.new(subscription).
                            create_and_return_subscription(token, coupon)

    if @subscription.save
      if data[:status] == :ok
        render json: { subscription_id: @subscription.id,
                       status: @subscription.stripe_status,
                       completion_guid: @subscription.completion_guid,
                       client_secret: data[:client_secret] }, status: data[:status]
      else
        render json: { subscription_id: @subscription.id,
                       error: data[:error_message] }, status: data[:status]
      end
    else
      render json: { subscription_id: @subscription.id,
                     error: data[:error_message] }, status: :error
    end
  end

  def paypal_subscription(subscription, _subscription_service, _params)
    subscription.save!
    @subscription = PaypalSubscriptionsService.new(subscription).create_and_return_subscription

    if @subscription.save
      redirect_to subscription.paypal_approval_url
    else
      Rails.logger.error "DEBUG: Subscription Failed to save for unknown reason - #{subscription.inspect}"
      flash[:error] = 'Your request was declined. Please contact us for assistance!'

      redirect_to new_subscription_url(subscription_plan_id: params[:subscription][:subscription_plan_id])
    end
  end

  def get_relevant_subscription_plans
    country  = IpAddress.get_country(request.remote_ip) || current_user.country
    currency = current_user.get_currency(country)

    if params[:plan_guid]
      SubscriptionPlan.includes(:exam_body, :currency).
        get_related_plans(current_user, currency, params[:exam_body_id], params[:plan_guid])
    else
      SubscriptionPlan.includes(:exam_body, :currency).
        get_relevant(current_user, currency, params[:exam_body_id])
    end
  end

  def update_status(status)
    case status
    when 'active', 'succeeded'
      @subscription.start
    when 'payment_action_required'
      @subscription.mark_payment_action_required
    when 'pending'
      @subscription.mark_pending!
    end
  end

  def set_flash
    return if params[:flash].blank?

    flash[:error] = params[:flash]
  end

  def subscription_params
    params.require(:subscription).permit(:user_id, :subscription_plan_id, :stripe_token, :terms_and_conditions,
                                         :hidden_coupon_code, :use_paypal, :completion_guid)
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end
end
