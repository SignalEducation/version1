# frozen_string_literal: true

module Subscriptions
  class PlanChangesController < ApplicationController
    before_action :logged_in_required
    before_action do
      ensure_user_has_access_rights(%w(student_user))
    end
    before_action :set_subscription

    def show
      Rails.logger.info "DataLayer Event: PlanChanges#show - Subscription: #{@subscription.id}, Revenue: #{@subscription.subscription_plan.price}, PlanName: #{@subscription.subscription_plan.name}, Brand: #{@subscription.subscription_plan.exam_body.name}" if @subscription
    end

    def new; end

    def create
      send("change_#{@subscription.subscription_type}_subscription",
           @subscription, plan_change_params[:subscription_plan_id].to_i)
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

    def change_stripe_subscription(subscription, plan_id)
      @subscription, data = StripeSubscriptionService.new(subscription).
                              change_plan(plan_id)

      if data[:status] == :ok
        render 'subscriptions/create'
      else
        render json: { subscription_id: @subscription.id,
                       error: data[:error_message] }, status: data[:status]
      end
    end

    def change_paypal_subscription(subscription, plan_id)
      @subscription =
        PaypalSubscriptionsService.new(subscription).change_plan(plan_id)

      redirect_to @subscription.paypal_approval_url
    end

    def plan_change_params
      params.require(:subscription).permit(:subscription_plan_id)
    end

    def set_subscription
      @subscription = Subscription.find_by(id: params[:subscription_id])
    end
  end
end
