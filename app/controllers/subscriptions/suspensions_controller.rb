class Subscriptions::SuspensionsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :get_subscription

  def create
    subscription_object = SubscriptionService.new(@subscription)
    if subscription_object.pause
      flash[:success] = I18n.t('controllers.subscriptions.update.flash.success')
    else
      Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong."
      flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
    end
    redirect_to account_url(anchor: 'subscriptions')
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to account_url(anchor: 'subscriptions')
  end

  def destroy
    subscription_object = SubscriptionService.new(@subscription)
    if subscription_object.re_activate
      flash[:success] = I18n.t('controllers.subscriptions.update.flash.success')
    else
      Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong."
      flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
    end
    redirect_to account_url(anchor: 'subscriptions')
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to account_url(anchor: 'subscriptions')
  end

  private

  def get_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end
end
