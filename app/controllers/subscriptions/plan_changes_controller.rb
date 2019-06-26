class Subscriptions::PlanChangesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :get_subscription

  def show
    Rails.logger.info "DataLayer Event: PlanChanges#show - Subscription: #{@subscription.id}, Revenue: #{@subscription.subscription_plan.price}, PlanName: #{@subscription.subscription_plan.name}, Brand: #{@subscription.subscription_plan.exam_body.name}" if @subscription
  end

  def new
  end

  def create
    subscription_object = SubscriptionService.new(@subscription)
    if @subscription = subscription_object.change_plan(plan_change_params[:subscription_plan_id].to_i)
      if subscription_object.stripe?
        @subscription.start
        subscription_object.validate_referral
        redirect_to subscriptions_plan_change_url(@subscription), notice: 'Your new plan is confirmed!'
      elsif subscription_object.paypal?
        redirect_to @subscription.paypal_approval_url
      end
    else
      Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong."
      flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
    end
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to account_url(anchor: 'subscriptions')
  end

  private

  def get_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end

  def plan_change_params
    params.require(:subscription).permit(:subscription_plan_id)
  end
end
