class SubscriptionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin individual_student corporate_customer))
  end
  before_action :get_subscription

  def update
    if @subscription
      @subscription = @subscription.upgrade_plan(updatable_params[:subscription_plan_id].to_i)
      if @subscription.try(:subscription_plan_id) == updatable_params[:subscription_plan_id].to_i && @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscriptions.update.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong. @subscription.errors: #{@subscription.errors.inspect}."
        flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
      end
      redirect_to profile_url(anchor: 'subscriptions')
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
    end
  end

  def destroy
    if @subscription
      if @subscription.cancel
        flash[:success] = I18n.t('controllers.subscriptions.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.subscriptions.destroy.flash.error')
      end
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    end
    redirect_to profile_url(anchor: 'subscriptions')
  end

  protected

  def updatable_params
    params.require(:subscription).permit(:subscription_plan_id)
  end

  def get_subscription
    @subscription = current_user.admin? ?
            Subscription.find_by_id(params[:id]) :
            current_user.subscriptions.find_by_id(params[:id])
  end

end
