# frozen_string_literal: true

module InvoiceReport
  extend ActiveSupport::Concern

  def inv_id
    self&.id
  end

  def user_email
    user.email
  end

  def invoice_created
    created_at.strftime('%Y-%m-%d')
  end

  def user_created
    user.created_at.strftime('%Y-%m-%d')
  end

  def sub_id
    subscription&.id
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

  def invoice_type
    created_at.strftime('%Y-%m-%d') > subscription.created_at.strftime('%Y-%m-%d') ? 'Recurring' : 'New'
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
    user&.country&.iso_code
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

  def hubspot_get_contact
    @hubspot_get_contact ||= HubSpot::Contacts.new.search(user_email)
    return nil if @hubspot_get_contact.nil? || @hubspot_get_contact['status'] == 'error'

    @hubspot_get_contact
  end

  def hubspot_source
    return '' if hubspot_get_contact.nil?

    hubspot_get_contact['properties']['hs_analytics_source']['value']
  end

  def hubspot_source_1
    return '' if hubspot_get_contact.nil?

    hubspot_get_contact['properties']['hs_analytics_source_data_1']['value'] if hubspot_get_contact['properties']['hs_analytics_source_data_1']
  end

  def hubspot_source_2
    return '' if hubspot_get_contact.nil?

    hubspot_get_contact['properties']['hs_analytics_source_data_2']['value'] if hubspot_get_contact['properties']['hs_analytics_source_data_2']
  end

  def user_subscriptions_revenue
    user.subscriptions_revenue
  end

  def user_orders_revenue
    user.orders_revenue
  end

  def user_total_revenue
    user.total_revenue
  end

  def coupon_code
    subscription&.coupon&.code
  end

  def coupon_id
    subscription&.coupon&.id
  end
end
