# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default(FALSE)
#  active             :boolean          default(FALSE)
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
#

require 'rails_helper'

describe Coupon do
  subject { FactoryBot.build(:coupon) }

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
    it { should validate_length_of(:code).is_at_most(255) }
    it { should_not validate_presence_of(:currency_id) }
    it { should validate_numericality_of(:currency_id) }
    it { should validate_presence_of(:duration) }
    it { should validate_inclusion_of(:duration).in_array(Coupon::DURATIONS) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_on_stripe).before(:create) }
    it { should callback(:activate).after(:create) }
    it { should callback(:delete_on_stripe).before(:destroy) }
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
    it { should respond_to(:destroyable?) }
    it { should respond_to(:available_payment_intervals) }
    it { should respond_to(:amount_or_percent_off) }
    it { should respond_to(:duration_months_if_repeating) }
    it { should respond_to(:currency_if_amount_off_set) }
    it { should respond_to(:update_redeems) }
    it { should respond_to(:deactivate) }
  end

end
