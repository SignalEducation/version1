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
#  livemode           :boolean          default(TRUE)
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

describe Refund do

  it { expect(Refund.const_defined?(:REASONS)).to eq(true) }

  describe 'relationships' do
    it { should belong_to(:charge) }
    it { should belong_to(:invoice) }
    it { should belong_to(:subscription) }
    it { should belong_to(:user) }
    it { should belong_to(:manager) }
  end

  describe 'validations' do
    before(:each) do
      response_body = {}
      stub_request(:post, "https://api.stripe.com/v1/refunds").
          with(
              headers: {
                'Accept'=>'*/*',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
                'Content-Type'=>'application/x-www-form-urlencoded',
                'Stripe-Version'=>'2019-05-16',
                'User-Agent'=>'Stripe/v1 RubyBindings/4.21.3'
              }).
          to_return(status: 200, body: response_body.to_json, headers: {})
    end


    it { should validate_presence_of(:stripe_guid) }

    it 'is invalid without a charge' do
      expect(build_stubbed(:refund, charge: nil)).not_to be_valid
    end

    it { should validate_presence_of(:stripe_charge_guid) }

    it 'is invalid without an invoice' do
      expect(build_stubbed(:refund, invoice: nil)).not_to be_valid
    end

    it 'is invalid without a subscription' do
      expect(build_stubbed(:refund, subscription: nil)).not_to be_valid
    end

    it 'is invalid without a manager' do
      expect(build_stubbed(:refund, manager: nil)).not_to be_valid
    end

    it 'is invalid without a user' do
      expect(build_stubbed(:refund, user: nil)).not_to be_valid
    end

    it { should validate_presence_of(:amount) }

    it { should validate_presence_of(:reason) }

    it { should validate_presence_of(:status) }

    xit { should validate_presence_of(:stripe_refund_data) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_on_stripe).before(:validation) }
  end

  describe 'scopes' do
    it { expect(Refund).to respond_to(:all_in_order) }
  end


  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end

end
