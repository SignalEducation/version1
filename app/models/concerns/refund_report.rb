# frozen_string_literal: true

module RefundReport
  extend ActiveSupport::Concern

  def refund_id
    self&.id
  end

  def refunded_on
    created_at.strftime('%Y-%m-%d')
  end

  def refund_status
    status
  end

  def stripe_id
    stripe_guid
  end

  def refund_amount
    amount
  end

  def inv_total
    invoice.total
  end

  def inv_created
    invoice.created_at.strftime('%Y-%m-%d')
  end

  def invoice_id
    invoice&.id
  end

  def invoice_type
    created_at.strftime('%Y-%m-%d') > subscription.created_at.strftime('%Y-%m-%d') ? 'Recurring' : 'New'
  end

  def email
    user.email
  end

  def user_created
    user.created_at.strftime('%Y-%m-%d')
  end

  def sub_created
    subscription&.created_at&.strftime('%Y-%m-%d')
  end

  def sub_exam_body
    subscription&.subscription_plan&.exam_body&.name
  end

  def sub_status
    subscription&.state
  end

  def sub_type
    subscription&.kind
  end

  def payment_provider
    subscription&.subscription_type
  end

  def sub_stripe_guid
    subscription&.stripe_guid
  end

  def sub_paypal_guid
    subscription&.paypal_subscription_guid
  end

  def payment_interval
    subscription.subscription_plan.payment_frequency_in_months
  end

  def plan_name
    subscription.subscription_plan.name
  end

  def currency_symbol
    subscription.subscription_plan.currency.iso_code
  end

  def plan_price
    subscription.subscription_plan.price
  end

  def card_country
    user&.subscription_payment_cards&.all_default_cards&.first&.account_country
  end

  def user_country
    user&.country&.name
  end

  def first_visit
    user.ahoy_visits.order(:started_at)&.first
  end

  def first_visit_date
    first_visit ? first_visit.started_at.strftime('%Y-%m-%d') : ''
  end

  def first_visit_landing_page
    first_visit ? first_visit.landing_page : ''
  end

  def first_visit_referrer
    first_visit ? first_visit.referrer : ''
  end

  def first_visit_referring_domain
    first_visit ? first_visit.referring_domain : ''
  end

  def first_visit_source
    first_visit&.utm_source || ''
  end

  def first_visit_medium
    first_visit ? first_visit.utm_medium : ''
  end

  def first_visit_search_keyword
    first_visit ? first_visit.search_keyword : ''
  end

  def first_visit_country
    first_visit ? first_visit.country : ''
  end

  def first_visit_utm_campaign
    first_visit ? first_visit.utm_campaign : ''
  end
end
