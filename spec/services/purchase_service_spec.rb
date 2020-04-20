# frozen_string_literal: true

require 'rails_helper'

describe PurchaseService, type: :service do
  describe '#create_purchase' do
    it 'calls #create_purchase on StripeService for Stripe purchases' do
      order = create(:order, :for_stripe)
      service = PurchaseService.new(order)
      expect_any_instance_of(StripeService).to receive(:create_purchase).with(order)

      service.create_purchase
    end

    it 'calls #create_purchase on PaypalService for PayPal purchases' do
      order = create(:order, :for_paypal)
      service = PurchaseService.new(order)
      expect_any_instance_of(PaypalService).to receive(:create_purchase).with(order)
      expect(order).to receive(:save!)

      service.create_purchase
    end
  end

  describe '#paypal?' do
    it 'returns TRUE if the order has use_paypal assigned' do
      order = build_stubbed(:order, use_paypal: 'true')

      expect(PurchaseService.new(order).paypal?).to be true
    end

    it 'returns TRUE if the order has a paypal_guid' do
      order = build_stubbed(:order, paypal_guid: 'test_guid')

      expect(PurchaseService.new(order).paypal?).to be true
    end

    it 'returns FALSE if use_paypal and paypal_guid are nil' do
      order = build_stubbed(:order, paypal_guid: nil)

      expect(PurchaseService.new(order).paypal?).to be false
    end
  end

  describe '#stripe?' do
    it 'returns TRUE if the order has a stripe_payment_method_id' do
      order = build_stubbed(:order, :for_stripe)

      expect(PurchaseService.new(order).stripe?).to be true
    end

    it 'returns TRUE if the order has a stripe_guid' do
      order = build_stubbed(:order, stripe_guid: 'test_guid')

      expect(PurchaseService.new(order).stripe?).to be true
    end

    it 'returns FALSE if stripe_payment_method_id and stripe_guid are nil' do
      order = build_stubbed(:order, stripe_guid: nil, stripe_payment_method_id: nil)

      expect(PurchaseService.new(order).stripe?).to be false
    end
  end
end
