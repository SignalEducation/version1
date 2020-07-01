# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'order_report' do
  let(:obj) { create(:order) }

  describe 'Methods used to build the order csv' do
    it { expect(obj.order_id).to eq(obj.id) }
    it { expect(obj.order_created).to eq(obj.created_at.strftime('%Y-%m-%d')) }
    it { expect(obj.name).to eq(obj.product.group.name) }
    it { expect(obj.product_name).to eq(obj.product.name) }
    it { expect(obj.stripe_id).to eq(obj.stripe_payment_intent_id) }
    it { expect(obj.product_type).to eq(obj.product.product_type) }
    it { expect(obj.leading_symbol).to eq(obj.product.currency.leading_symbol) }
    it { expect(obj.price).to eq(obj.product.price) }
    it { expect(obj.user_country).to eq(obj.user.country.name) }
    it { expect(obj.card_country).to eq(obj.user&.subscription_payment_cards&.all_default_cards&.first&.account_country) }
  end
end
