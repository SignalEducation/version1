# frozen_string_literal: true

module Subscriptions
  class CancellationsController < ApplicationController
    before_action :logged_in_required
    before_action do
      ensure_user_has_access_rights(%w[student_user system_requirements_access])
    end
    before_action :set_subscription

    def new
      if params[:role] == 'admin'
        @layout = 'management'
        render :admin_new
      end
    end

    def create
      ActiveRecord::Base.transaction do
        if @subscription.update(subscription_params) && cancel_subscription(@subscription)
          flash[:success] = I18n.t('controllers.subscriptions.destroy.flash.success')
          flash[:datalayer_cancel] = @subscription.user_readable_name

          redirect_to account_url(anchor: 'account-info')
        else
          Rails.logger.warn "WARN: Subscription#delete failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
          flash[:error] = I18n.t('controllers.subscriptions.destroy.flash.error')
          @subscription.errors.add(:cancellation_reason, 'please select an option')

          redirect_to redirect_back(fallback_location: root_path)
        end
      end
    rescue Learnsignal::SubscriptionError
      flash[:error] = I18n.t('controllers.subscriptions.destroy.flash.error')
      redirect_back(fallback_location: root_path)
    end

    private

    def cancel_subscription(subscription)
      if %w[past_due pending_3d_secure].include?(subscription.state)
        subscription.immediate_cancel
      else
        subscription.cancel_by_user
      end
    end

    def set_subscription
      @subscription = Subscription.find_by(id: params[:subscription_id])
    end

    def subscription_params
      params.require(:subscription).permit(
        :cancellation_reason,
        :cancellation_note,
        :cancelled_by_id,
        :cancelling_subscription
      )
    end
  end
end
