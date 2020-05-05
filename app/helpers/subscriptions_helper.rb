# frozen_string_literal: true

module SubscriptionsHelper
  def plans_partials(params, subscription, plans)
    plan_guid      = params[:plan_guid]
    plan_frequency = params[:prioritise_plan_frequency].to_i
    partial        = plan_checks(plan_guid, plan_frequency, plans) ? 'single_plan_checkout' : 'multi_plans'

    render partial: partial, locals: { subscription: subscription, plans: plans }
  end

  private

  def plan_checks(plan_guid, plan_frequency, plans)
    plan_guid_check(plan_guid, plans) || plan_frequency_check(plan_frequency)
  end

  def plan_guid_check(plan_guid, plans)
    plan_guid.present? && plans.map(&:guid).include?(plan_guid)
  end

  def plan_frequency_check(plan_frequency)
    plan_frequency.present? && SubscriptionPlan::PAYMENT_FREQUENCIES.include?(plan_frequency)
  end
end
