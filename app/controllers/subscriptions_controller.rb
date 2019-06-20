# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string
#  next_renewal_date        :date
#  complimentary            :boolean          default(FALSE), not null
#  stripe_status            :string
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string
#  stripe_customer_data     :text
#  livemode                 :boolean          default(FALSE)
#  active                   :boolean          default(FALSE)
#  terms_and_conditions     :boolean          default(FALSE)
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#  state                    :string
#  cancelled_at             :datetime
#  cancellation_reason      :string
#  cancellation_note        :text
#

class SubscriptionsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :get_subscription, except: [:new, :create]
  before_action :set_flash, only: :new
  

  def show
    @subscription = Subscription.find(params[:id])
    redirect_to dashboard_path unless @subscription.user_id == current_user.id
  end

  def new
    #redirect_to already_subscribed_url

    if ExamBody.exists?(params[:exam_body_id]) 
      current_user.preferred_exam_body.present?
    else
      redirect_to edit_preferred_exam_body_path
      return
    end

    if current_user.active_subscriptions_for_exam_body(params[:exam_body_id])
      if current_user.active_subscriptions_for_exam_body(params[:exam_body_id]).count > 0

        other_plans = SubscriptionPlan.get_related_plans(current_user, 
          current_user.active_subscriptions_for_exam_body(params[:exam_body_id]).last.currency, params[:exam_body_id], 
          current_user.active_subscriptions_for_exam_body(params[:exam_body_id]).last.subscription_plan.guid 
          )
        if other_plans.count  <= 1
         flash[:warning] = 'No other plans exist'
         redirect_to account_url         
        else
          redirect_to new_subscriptions_plan_change_url(id: current_user.active_subscriptions_for_exam_body(params[:exam_body_id]).first.id)
        end
      end
    end

      if !current_user.preferred_exam_body.present? && !params[:exam_body_id] && ExamBody.exists?(params[:exam_body_id]) 
        #redirect_to already_subscribed_url
  

        redirect_to edit_preferred_exam_body_path
      elsif current_user.standard_student_user?
        @plans, country = get_relevant_subscription_plans
        @yearly_plan = @plans.yearly.first
        
        if params[:prioritise_plan_frequency].present?
          @subscription = Subscription.new(
            user_id: current_user.id,
            subscription_plan_id: @plans.where(payment_frequency_in_months: params[:prioritise_plan_frequency].to_i).first.id
          )
        elsif params[:plan_guid].present? && @plans.map(&:guid).include?(params[:plan_guid])
          @subscription = Subscription.new(
            user_id: current_user.id,
            subscription_plan_id: @plans.where(guid: params[:plan_guid].to_s).first.id
          )
        else
          @subscription = Subscription.new(
            user_id: current_user.id,
            subscription_plan_id: params[:subscription_plan_id] || @plans.where(payment_frequency_in_months: 12)&.first&.id
          )
        end
        #IntercomUpgradePageLoadedEventWorker.perform_async(current_user.id, country.name) unless Rails.env.test?
        seo_title_maker('Course Membership Payment | LearnSignal', 'Pay monthly, quarterly or yearly for learnsignal and access professional course materials, expert notes and corrected questions anytime, anywhere.', false)
      else
        redirect_to root_url
      end
    
  end

  def create
    @subscription = Subscription.new(subscription_params)

    subscription_object = SubscriptionService.new(@subscription)
    subscription_object.check_valid_subscription?(params)
    subscription_object.check_for_valid_coupon?(params[:hidden_coupon_code])
    @subscription = subscription_object.create_and_return_subscription(params)
    
    if @subscription && @subscription.save
      if subscription_object.stripe?
        @subscription.start
        subscription_object.validate_referral
        redirect_to personal_upgrade_complete_url, notice: 'Your subscription is confirmed!'
      elsif subscription_object.paypal?
        redirect_to @subscription.paypal_approval_url
      end
    else
      Rails.logger.info "DEBUG: Subscription Failed to save for unknown reason - #{@subscription.inspect}"
      flash[:error] = 'Your request was declined. Please contact us for assistance!'
      redirect_to new_subscription_url(subscription_plan_id: @subscription.subscription_plan_id)
    end
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to new_subscription_url(subscription_plan_id: @subscription.subscription_plan_id)
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
          redirect_to personal_upgrade_complete_url
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
    @subscription = current_user.subscriptions.last
    @subscription_category = 'Subscription'

    seo_title_maker('Thank You for Subscribing | LearnSignal',
                    'Thank you for subscribing to learnsignal you can now access professional course materials, expert notes and corrected questions anytime, anywhere.',
                    false)
  end

  def un_cancel_subscription
    if @subscription && @subscription.stripe_status == 'canceled-pending'
      @subscription.un_cancel

      if @subscription && @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscriptions.un_cancel.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionsController#un_cancel_subscription - something went wrong."
        flash[:error] = I18n.t('controllers.subscriptions.un_cancel.flash.error')
      end
      redirect_to account_url(anchor: 'subscriptions')
    else
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to account_url(anchor: 'subscriptions')
    end
  end

  #Setting current subscription to cancel-pending or canceled. We don't actually delete the Subscription Record
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
      redirect_to account_url(anchor: 'subscriptions')
    else
      redirect_to user_subscription_status_url(@subscription.user)
    end
  end

  private

  def get_relevant_subscription_plans
    country = IpAddress.get_country(request.remote_ip) || current_user.country
    currency = current_user.get_currency(country)
    if params[:plan_guid]
      plans = SubscriptionPlan.get_related_plans(
          current_user,
          currency,
          params[:exam_body_id],
          params[:plan_guid]
      )
    else
      plans = SubscriptionPlan.get_relevant(
          current_user,
          currency,
          params[:exam_body_id]
      )
    end
    return plans, country
  end

  def set_flash
    if params[:flash].present?
      flash[:error] = params[:flash]
    end
  end

  def subscription_params
    params.require(:subscription).permit(:user_id, :subscription_plan_id, :stripe_token, :terms_and_conditions,
                                         :hidden_coupon_code, :use_paypal)
  end

  def get_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end

  def already_subscribed
  end

end
