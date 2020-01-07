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
#  livemode                     :boolean          default(FALSE)
#  stripe_order_id              :string
#  paid                         :boolean          default(FALSE)
#  refunded                     :boolean          default(FALSE)
#  stripe_refunds_data          :text
#  status                       :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  original_event_data          :text
#

require 'rails_helper'

describe Charge do

  describe 'relationships' do
    it { should belong_to(:subscription) }
    it { should belong_to(:invoice) }
    it { should belong_to(:user) }
    it { should belong_to(:subscription_payment_card) }
    it { should belong_to(:currency) }
    it { should belong_to(:coupon).optional }
    it { should belong_to(:stripe_api_event).optional }
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


  describe 'class methods' do
    it { expect(Charge).to respond_to(:create_from_stripe_data) }
    it { expect(Charge).to respond_to(:update_refund_data) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:refundable?) }
  end

end
