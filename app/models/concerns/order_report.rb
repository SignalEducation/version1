# frozen_string_literal: true

module OrderReport
  extend ActiveSupport::Concern

  def order_id
    self&.id
  end

  def order_created
    created_at.utc.strftime('%Y-%m-%d')
  end

  def name
    product&.group&.name
  end

  def product_name
    product.name
  end

  def stripe_id
    stripe_payment_intent_id
  end

  def product_type
    product.product_type
  end

  def leading_symbol
    product.currency.leading_symbol
  end

  def price
    product.price
  end

  def user_country
    user&.country&.name
  end

  def card_country
    user&.subscription_payment_cards&.all_default_cards&.first&.account_country
  end

  def inv_id
    invoice&.id
  end

  def user_email
    user&.email
  end

  def invoice_created
    invoice&.created_at&.strftime('%Y-%m-%d')
  end

  def user_created
    user&.created_at
  end

  def sub_id; end

  def sub_created; end

  def sub_exam_body; end

  def sub_status; end

  def sub_type; end

  def sub_total; end

  def total; end

  def payment_provider
    stripe? ? 'Stripe' : 'PayPal'
  end

  def invoice_type; end

  def sub_stripe_guid; end

  def sub_paypal_guid; end

  def payment_interval; end

  def plan_name; end

  def currency_symbol; end

  def plan_price; end

  def first_visit; end

  def first_visit_date; end

  def first_visit_landing_page; end

  def first_visit_referrer; end

  def first_visit_referring_domain; end

  def first_visit_source; end

  def first_visit_medium; end

  def first_visit_search_keyword; end

  def first_visit_country; end

  def first_visit_utm_campaign; end

  def hubspot_get_contact; end

  def hubspot_source; end

  def hubspot_source_1; end

  def hubspot_source_2; end

  def user_subscriptions_revenue
    user.subscriptions_revenue
  end

  def user_orders_revenue
    user.orders_revenue
  end

  def user_total_revenue
    user.total_revenue
  end
end
