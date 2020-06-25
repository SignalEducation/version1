# frozen_string_literal: true

module OrderReport
  extend ActiveSupport::Concern

  def order_id
    self&.id
  end

  def order_created
    created_at.strftime('%Y-%m-%d')
  end

  def name
    product.group.name
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
    user.country.name
  end

  def card_country
    user&.subscription_payment_cards&.all_default_cards&.first&.account_country
  end
end
