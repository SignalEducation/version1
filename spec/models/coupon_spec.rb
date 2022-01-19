# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default("false")
#  active             :boolean          default("false")
#  amount_off         :integer
#  duration           :string
#  duration_in_months :integer
#  max_redemptions    :integer
#  percent_off        :integer
#  redeem_by          :datetime
#  times_redeemed     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_coupon_data :text
#  exam_body_id       :integer
#  monthly_interval   :boolean          default("true")
#  quarterly_interval :boolean          default("true")
#  yearly_interval    :boolean          default("true")
#

require 'rails_helper'

describe Coupon do
  let(:coupon) { build(:coupon) }

  describe 'constants' do
    it { expect(Coupon.const_defined?(:DURATIONS)).to eq(true) }
  end

  describe 'relationships' do
    it { should belong_to(:currency) }
    it { should belong_to(:exam_body) }
    it { should have_many(:charges) }
    it { should have_many(:subscriptions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should_not allow_value('coupon_not_allowed_30%').for(:code) }
    it { should validate_length_of(:code).is_at_most(255) }
    it { should_not validate_presence_of(:currency_id) }
    it { should validate_numericality_of(:currency_id) }
    it { should validate_presence_of(:duration) }
    it { should validate_inclusion_of(:duration).in_array(Coupon::DURATIONS) }
  end

  describe 'callbacks' do
    it { should callback(:create_on_stripe).before(:create) }
    it { should callback(:update_on_stripe).after(:update) }
    it { should callback(:activate).after(:create) }
  end

  describe 'scopes' do
    it { expect(Coupon).to respond_to(:all_in_order) }
    it { expect(Coupon).to respond_to(:all_active) }
  end

  describe 'class methods' do
    it { expect(Coupon).to respond_to(:verify_coupon_and_get_discount) }
    it { expect(Coupon).to respond_to(:get_and_verify) }
  end

  describe 'instance methods' do
    it { should respond_to(:available_payment_intervals) }
    it { should respond_to(:amount_or_percent_off) }
    it { should respond_to(:duration_months_if_repeating) }
    it { should respond_to(:currency_if_amount_off_set) }
    it { should respond_to(:update_redeems) }
    it { should respond_to(:deactivate) }
  end

  describe 'Factory' do
    it { expect(coupon).to be_a Coupon }
    it { expect(coupon).to be_valid }
  end

  describe 'Methods' do
    let(:plan) { build(:subscription_plan) }

    before do
      allow(Coupon).to receive(:find_by).and_return(coupon)
      allow(SubscriptionPlan).to receive(:find).and_return(plan)
    end

    describe '#verify_coupon_and_get_discount' do
      let(:coupon)    { build(:coupon) }
      let(:exam_body) { build(:exam_body) }

      context 'actived coupon but invalid' do
        it 'coupons can\'t be applied because of plan' do
          plan.subscription_plan_category_id = 1
          discount = Coupon.verify_coupon_and_get_discount(coupon.code, plan)

          expect(discount).to include(false, plan.currency.format_number(plan.price), 'Coupons can\'t be applied to this plan')
        end

        it 'coupons can\'t be applied because of exam body' do
          coupon.exam_body = exam_body
          discount = Coupon.verify_coupon_and_get_discount(coupon.code, plan)

          expect(discount).to include(false, plan.currency.format_number(plan.price), "Coupon can't be applied to #{plan.exam_body.name} plans")
        end

        it 'coupons can\'t be applied because of selected plan' do
          coupon.monthly_interval   = false
          coupon.quarterly_interval = false
          coupon.yearly_interval    = false

          discount = Coupon.verify_coupon_and_get_discount(coupon.code, plan)
          expect(discount).to include(false, plan.currency.format_number(plan.price), 'Coupon can\'t be applied to the selected plan')
        end
      end

      # TODO,(Giordano), move the calc code to outside verify_coupon_and_get_discount method.
      # Remove the duplicated calc code from here when it's done.
      context 'actived coupon' do
        it 'amount_off' do
          coupon.amount_off = rand(1..99)
          coupon.currency   = plan.currency
          discounted_number = plan.price.to_f - (coupon.amount_off / 100).to_f
          discounted_price  = plan.currency.format_number(discounted_number)
          discount          = Coupon.verify_coupon_and_get_discount(coupon.code, plan)

          expect(discount).to include(true, discounted_price, 'Invalid Code')
        end

        it 'percent_off' do
          coupon.percent_off = rand(1..99)
          discounted_number  = plan.price.to_f - ((plan.price.to_f / 100) * coupon.percent_off)
          discounted_price   = plan.currency.format_number(discounted_number)
          discount           = Coupon.verify_coupon_and_get_discount(coupon.code, plan)

          expect(discount).to include(true, discounted_price, 'Invalid Code')
        end
      end

      context 'no actived coupon' do
        let(:coupon) { build(:coupon) }

        it 'return invalid discount' do
          coupon.active = false
          discount = Coupon.verify_coupon_and_get_discount(coupon.code, plan)

          expect(discount).to include(false, plan.currency.format_number(plan.price), 'Invalid Code')
        end
      end
    end

    describe '#get_and_verify' do
      let(:coupon)    { build(:coupon) }
      let(:exam_body) { build(:exam_body) }

      context 'actived coupon' do
        it 'amount_off' do
          coupon.amount_off = rand(1..99)
          verified_coupon   = Coupon.get_and_verify(coupon.code, plan)
          expect(verified_coupon).to be_nil
        end

        it 'different exam body' do
          coupon.exam_body = exam_body
          verified_coupon  = Coupon.get_and_verify(coupon.code, plan)
          expect(verified_coupon).to be_nil
        end
      end
    end
  end
end
