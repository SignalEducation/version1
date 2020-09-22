# frozen_string_literal: true

module Subscriptions
  class PlanChangesController < ApplicationController
    before_action :logged_in_required
    before_action do
      ensure_user_has_access_rights(%w[student_user])
    end
    before_action :set_subscription

    def show
      Rails.logger.info "DataLayer Event: PlanChanges#show - Subscription: #{@subscription.id}, Revenue: #{@subscription.subscription_plan.price}, PlanName: #{@subscription.subscription_plan.name}, Brand: #{@subscription.subscription_plan.exam_body.name}" if @subscription
    end

    def new
      if %w[active canceled-pending pending_cancellation].include?(@subscription.state)
        @card = default_payment_card(@subscription.user_id)
      else
        flash[:warning] = 'There is an issue with your current subscription. This must be resolved before changing plan.'
        redirect_to account_url(anchor: 'account-info')
      end
    end

    def create
      @subscription.stripe? ? change_stripe_subscription : change_paypal_subscription
    rescue Learnsignal::SubscriptionError => e
      if request.xhr?
        render json: { subscription_id: @subscription&.id,
                       error: e.message }, status: :bad_request
      else
        flash[:error] = e.message
        redirect_to account_url(anchor: 'account-info')
      end
    end

    def status_from_stripe
      case params[:status]
      when 'active', 'succeeded'
        @subscription.start
      end
    end

    private

    def change_stripe_subscription
      kind                = params[:kind]
      coupon              = params[:hidden_coupon_code]
      plan_id             = params[:subscription][:subscription_plan_id]
      sub_service         = StripeSubscriptionService.new(@subscription)
      @subscription, data = sub_service.change_plan(coupon, plan_id)

      if data[:status] == :ok
        retrieved_subscription = StripeSubscriptionService.new(@subscription).retrieve_subscription
        @subscription.un_cancel if retrieved_subscription[:cancel_at_period_end]
        @subscription.update(kind: kind)
        render 'subscriptions/create'
      else
        render json: { subscription_id: @subscription.id,
                       error: data[:error_message] }, status: data[:status]
      end
    end

    def change_paypal_subscription
      kind          = params[:subscription][:kind]
      plan_id       = params[:subscription][:subscription_plan_id]
      @subscription = PaypalSubscriptionsService.new(@subscription).change_plan(plan_id)
      @subscription.update(kind: kind)
      redirect_to @subscription.paypal_approval_url
    end

    def default_payment_card(user_id)
      @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: user_id).all_in_order
      @default_payment_card       = @subscription_payment_cards.all_default_cards.first
    end

    def plan_change_params
      params.require(:subscription).permit(:subscription_plan_id, :kind, :hidden_coupon_code)
    end

    def set_subscription
      @subscription = Subscription.find_by(id: params[:subscription_id])
    end
  end
end
