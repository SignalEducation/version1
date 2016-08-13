# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  corporate_customer_id :integer
#  subscription_plan_id  :integer
#  stripe_guid           :string
#  next_renewal_date     :date
#  complimentary         :boolean          default(FALSE), not null
#  current_status        :string
#  created_at            :datetime
#  updated_at            :datetime
#  stripe_customer_id    :string
#  stripe_customer_data  :text
#  livemode              :boolean          default(FALSE)
#

class SubscriptionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin individual_student))
  end
  before_action :get_subscription, except: :create

  def create
    @subscription = Subscription.new(creatable_params)
    @subscription.stripe_customer_id = current_user.admin? ?
            User.find_by_id(params[:subscription][:user_id]).stripe_customer_id :
            current_user.stripe_customer_id
    if @subscription.save
      flash[:success] = I18n.t('controllers.subscriptions.create.flash.success')
    else
      Rails.logger.warn "WARN: Subscription#create failed to create a new (reactivated) subscription. Errors:#{@subscription.errors.inspect}"
      flash[:error] = I18n.t('controllers.subscriptions.create.flash.error')
    end
    redirect_to account_url(anchor: 'subscriptions')
  end

  def update
    if @subscription
      @subscription = (@subscription.current_status == 'canceled-pending') ?
              @subscription.un_cancel :
              @subscription.upgrade_plan(updatable_params[:subscription_plan_id].to_i)
      if @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscriptions.update.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionsController#update - something went wrong. @subscription.errors: #{@subscription.errors.inspect}."
        flash[:error] = I18n.t('controllers.subscriptions.update.flash.error')
      end
      redirect_to account_url(anchor: 'subscriptions')
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
    end
  end

  def destroy
    if @subscription
      if @subscription.cancel(account_url)
        flash[:success] = I18n.t('controllers.subscriptions.destroy.flash.success')
      else
        Rails.logger.warn "WARN: Subscription#delete failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
        flash[:error] = I18n.t('controllers.subscriptions.destroy.flash.error')
      end
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    end
    redirect_to account_url(anchor: 'subscriptions')
  end

  protected

  def creatable_params
    params.require(:subscription).permit(:subscription_plan_id, :user_id)
  end

  def updatable_params
    params.require(:subscription).permit(:subscription_plan_id)
  end

  def get_subscription
    @subscription = current_user.admin? ?
            Subscription.find_by_id(params[:id]) :
            current_user.subscriptions.find_by_id(params[:id])
  end

end
