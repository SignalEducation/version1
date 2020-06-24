# == Schema Information
#
# Table name: charges
#
#  id                           :integer          not null, primary key
#  subscription_id              :integer
#  invoice_id                   :integer
#  user_id                      :integer
#  subscription_payment_card_id :integer
#  currency_id                  :integer
#  coupon_id                    :integer
#  stripe_api_event_id          :integer
#  stripe_guid                  :string
#  amount                       :integer
#  amount_refunded              :integer
#  failure_code                 :string
#  failure_message              :text
#  stripe_customer_id           :string
#  stripe_invoice_id            :string
#  livemode                     :boolean          default("false")
#  stripe_order_id              :string
#  paid                         :boolean          default("false")
#  refunded                     :boolean          default("false")
#  stripe_refunds_data          :text
#  status                       :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  original_event_data          :text
#

require 'rails_helper'

RSpec.describe Charge, type: :model do
  let(:user)         { create(:student_user) }
  let(:charge)       { build(:charge) }
  let(:invoice)      { create(:invoice) }
  let(:invoice)      { create(:invoice) }
  let(:payment_card) { create(:subscription_payment_card) }

  describe 'relationships' do
    it { should belong_to(:subscription) }
    it { should belong_to(:invoice) }
    it { should belong_to(:user) }
    it { should belong_to(:subscription_payment_card) }
    it { should belong_to(:currency) }
    it { should belong_to(:coupon) }
    it { should belong_to(:stripe_api_event) }
    it { should have_many(:refunds) }
  end

  describe 'validations' do
    it { should validate_presence_of(:subscription_id) }
    it { should validate_numericality_of(:subscription_id) }
    it { should validate_presence_of(:invoice_id) }
    it { should validate_numericality_of(:invoice_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_numericality_of(:user_id) }
    it { should validate_presence_of(:subscription_payment_card_id) }
    it { should validate_numericality_of(:subscription_payment_card_id) }
    it { should validate_presence_of(:currency_id) }
    it { should validate_numericality_of(:currency_id) }
    it { should_not validate_presence_of(:coupon_id) }
    it { should validate_numericality_of(:coupon_id) }
    it { should validate_presence_of(:stripe_guid) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:stripe_customer_id) }
    it { should validate_presence_of(:stripe_invoice_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(Charge).to respond_to(:all_in_order) }
  end

  describe 'methods' do
    before do
      allow_any_instance_of(StripeApiEvent).to receive(:sync_data_from_stripe).and_return(true)
      allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
      allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
    end

    context 'create charge' do
      it '#create_from_stripe_data' do
        allow(Charge).to receive(:create!).and_return(true)

        event = { invoice: invoice.stripe_guid,
                  customer: user.stripe_customer_id,
                  payment_method: payment_card.stripe_card_guid }

        expect(Charge.create_from_stripe_data(event)).to be(true)
      end
    end

    context 'error in create charge' do
      it '#create_from_stripe_data' do
        event = { invoice: invoice.stripe_guid,
                  customer: user.stripe_customer_id,
                  payment_method: payment_card.stripe_card_guid }

        expect(Charge.create_from_stripe_data(event)).to be(false)
      end
    end

    it '#update_refund_data' do
      allow(Charge).to receive(:find_by).and_return(charge)
      allow(Charge).to receive(:update).and_return(true)

      event = { invoice: invoice.stripe_guid,
                customer: user.stripe_customer_id,
                payment_method: payment_card.stripe_card_guid,
                refunds: {},
                id: charge.stripe_guid }

      expect(Charge.update_refund_data(event)).to be(charge)
    end

    it '.destroyable?' do
      expect(charge.destroyable?).to be(false)
    end

    it '.refundable?' do
      expect(charge.refundable?).to be(false)
    end
  end
end
