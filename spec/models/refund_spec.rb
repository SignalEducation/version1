# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default("true")
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

describe Refund, type: :model do
  let(:refund) { build(:refund) }

  describe 'Should Respond' do
    it { should respond_to(:stripe_guid) }
    it { should respond_to(:charge_id) }
    it { should respond_to(:stripe_charge_guid) }
    it { should respond_to(:invoice_id) }
    it { should respond_to(:subscription_id) }
    it { should respond_to(:user_id) }
    it { should respond_to(:manager_id) }
    it { should respond_to(:amount) }
    it { should respond_to(:reason) }
    it { should respond_to(:status) }
    it { should respond_to(:livemode) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:charge) }
    it { should belong_to(:invoice) }
    it { should belong_to(:subscription) }
    it { should belong_to(:user) }
    it { should belong_to(:manager) }
  end

  describe 'Validations' do
    before do
      allow_any_instance_of(Refund).to receive(:create_on_stripe).and_return(true)
    end

    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:reason) }
    it { should validate_presence_of(:charge_id) }
    it { should validate_presence_of(:invoice_id) }
    it { should validate_presence_of(:subscription_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:manager_id) }
    it { should validate_inclusion_of(:reason).in_array(%w[duplicate fraudulent requested_by_customer]) }
    it { should validate_uniqueness_of(:stripe_guid) }
    it { should validate_numericality_of(:charge_id) }
    it { should validate_numericality_of(:invoice_id) }
    it { should validate_numericality_of(:subscription_id) }
    it { should validate_numericality_of(:user_id) }
    it { should validate_numericality_of(:manager_id) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_on_stripe).after(:create) }
  end

  describe 'scopes' do
    it { expect(Refund).to respond_to(:all_in_order) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end
end
