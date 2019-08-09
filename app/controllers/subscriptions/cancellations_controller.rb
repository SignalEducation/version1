class Subscriptions::CancellationsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :get_subscription

  def new
  end

  def create
    @subscription.cancelling_subscription = true
    if @subscription.update(subscription_params) && @subscription.cancel_by_user
      flash[:success] = I18n.t('controllers.subscriptions.destroy.flash.success')
      flash[:datalayer_cancel] = @subscription.user_readable_name

      redirect_to account_url(anchor: 'account-info')
    else
      Rails.logger.warn "WARN: Subscription#delete failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
      flash[:error] = I18n.t('controllers.subscriptions.destroy.flash.error')
      @subscription.errors.add(:cancellation_reason, 'please select an option')

      redirect_to new_subscriptions_cancellation_path(id: @subscription.id)
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:cancellation_reason, :cancellation_note)
  end

  def get_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end
end
