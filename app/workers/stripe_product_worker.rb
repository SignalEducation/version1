# frozen_string_literal: true

class StripeProductWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(product_id, action)
    product = Product.find(product_id)
    StripeService.new.send("#{action}_product", product)
  end
end
