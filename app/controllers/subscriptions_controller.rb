# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  include Subscriptions::Support # concern/subscriptions/support.rb

  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[student_user]) }
  before_action :set_subscription, except: %i[new create personal_upgrade_complete]
  before_action :set_variables, only: :new
  before_action :set_flash, :redirects_conditions, only: :new

  def show
    redirect_to student_dashboard_path if @subscription.user_id != current_user.id
  end

  def new
    seo_title_maker('Course Membership Payment | Learnsignal', 'Pay monthly, quarterly or yearly for learnsignal and access professional course materials, expert notes and corrected questions anytime, anywhere.', false)
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to new_subscription_url(params.slice(:exam_body_id).to_unsafe_h)
  end

  def create
    valid_subscription_type?(params['payment-options'])
    @subscription        = Subscription.new(subscription_params)
    subscription_service = SubscriptionService.new(@subscription)
    subscription_service.check_valid_subscription?(params)
    subscription_service.check_for_valid_coupon?(params[:hidden_coupon_code])

    # call private stripe_subscription or paypal_subscription method
    send("#{params['payment-options']}_subscription",
         @subscription, subscription_service, params)
  rescue Learnsignal::SubscriptionError => e
    if request.xhr?
      render json: { subscription_id: @subscription&.id,
                     error: e.message }, status: :bad_request
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
          redirect_to subscription_plan_changes_url(subscription_id: @subscription.id), notice: 'Your new plan is confirmed!'
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
    coupon_data       = @subscription.coupon_data
    @coupon_code      = coupon_data.present? ? coupon_data[:code] : ''
    @discounted_price = coupon_data.present? ? coupon_data[:price_discounted]&.round(2) : ''

    ab_finished("#{@subscription&.subscription_plan&.exam_body&.group&.name_url}_pricing_link")
    Rails.logger.info "DataLayer Event: Subscription#personal_upgrade_complete - Subscription: #{@subscription.id} with completion_guid #{params[:completion_guid]}, Revenue: #{@subscription.subscription_plan.price}, PlanName: #{@subscription.subscription_plan.name}, Brand: #{@subscription.subscription_plan.exam_body.name}"
    seo_title_maker('Thank You for Subscribing | Learnsignal',
                    'Thank you for subscribing to learnsignal you can now access professional course materials, expert notes and corrected questions anytime, anywhere.',
                    false)
  end

  def un_cancel
    if @subscription.pending_cancellation? && SubscriptionService.new(@subscription).un_cancel
      flash[:success] = I18n.t('controllers.subscriptions.un_cancel.flash.success')
    else
      flash[:error] = I18n.t('controllers.subscriptions.un_cancel.flash.error')
    end
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
  ensure
    redirect_to account_url(anchor: 'account-info')
  end

  # Setting current subscription to cancel-pending or canceled. We don't actually delete the Subscription Record
  def destroy
    if @subscription.present?
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
      redirect_to user_subscription_url(@subscription.user)
    end
  end

  def status_from_stripe
    update_status(params[:status])
    render json: { status: @subscription&.state,
                   subscription_id: @subscription&.id }
  end

  def expire_incomplete
    stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_guid)
    stripe_subscription = stripe_subscription.delete.to_hash

    if stripe_subscription[:status] == 'incomplete_expired'
      @subscription.update_attributes(stripe_status: 'incomplete_expired')
      @subscription.mark_pending
    else
      @subscription.record_error
    end
  end

  private

  def stripe_subscription(subscription, subscription_service, params)
    token               = params[:subscription][:stripe_token]
    coupon              = subscription_service.coupon
    @subscription, data = StripeSubscriptionService.new(subscription).
                            create_and_return_subscription(token, coupon)

    if @subscription.save
      if data[:status] == :ok
        render :create
      else
        segment_payment_failed_event(subscription, data[:error_message], data[:status])
        render json: { subscription_id: @subscription.id,
                       error: data[:error_message] }, status: data[:status]

      end
    else
      segment_payment_failed_event(subscription, data[:error_message], data[:status])
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
      error_msg = "DEBUG: Subscription Failed to save for unknown reason - #{subscription.inspect}"
      segment_payment_failed_event(subscription, error_msg, 'error')
      Rails.logger.error error_msg
      flash[:error] = 'Your request was declined. Please contact us for assistance!'

      redirect_to new_subscription_url(subscription_plan_id: params[:subscription][:subscription_plan_id])
    end
  end

  def get_relevant_subscription_plans
    @currency =
      if current_user.currency_locked?
        current_user.currency
      else
        country = IpAddress.get_country(request.remote_ip) || current_user.country
        current_user.get_currency(country)
      end

    if params[:plan_guid]
      SubscriptionPlan.includes(:exam_body, :currency).
        get_related_plans(current_user, @currency, params[:exam_body_id], params[:plan_guid])
    else
      SubscriptionPlan.includes(:exam_body, :currency).
        get_relevant(current_user, @currency, params[:exam_body_id])
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

  def valid_subscription_type?(type)
    return if %w[stripe paypal].include?(type)

    raise Learnsignal::SubscriptionError, t('views.subscriptions.new_subscription.invalid_type')
  end

  def segment_payment_failed_event(subscription, error_msg, error_code)
    return if Rails.env.test?

    SegmentService.new.track_payment_failed_event(current_user, subscription, error_msg, error_code)
  end

  def set_variables
    if params[:exam_body_id].present?
      @exam_body    = ExamBody.find(params[:exam_body_id])
      @plans        = get_relevant_subscription_plans
      @kind         = current_user.subscriptions.for_exam_body(params[:exam_body_id]).where(state: %w[canceled cancelled]).empty? ? :new_subscription : :reactivation
      @subscription = Subscription.new(user_id: current_user.id,
                                       subscription_plan_id: filtered_plan&.id)
    else
      flash[:error] = 'Invalid request, please contact us for assistance!' if flash[:error].nil?
      redirect_to account_url(anchor: 'account-info')
    end
  end

  def set_flash
    return if params[:flash].blank?

    flash[:error] = params[:flash]
  end

  def subscription_params
    params.require(:subscription).permit(
      :user_id, :subscription_plan_id, :stripe_token, :terms_and_conditions,
      :hidden_coupon_code, :use_paypal, :completion_guid, :kind, :coupon_id)
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end
end
