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
require 'support/stripe_web_mock_helpers'

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
                  'Stripe-Version'=>'2017-06-05',
                  'User-Agent'=>'Stripe/v1 RubyBindings/4.5.0'
              }).
          to_return(status: 200, body: response_body.to_json, headers: {})
    end


    it { should validate_presence_of(:stripe_guid) }

    it { should validate_presence_of(:charge_id) }
    it { should validate_numericality_of(:charge_id) }

    it { should validate_presence_of(:stripe_charge_guid) }

    it { should validate_presence_of(:invoice_id) }
    it { should validate_numericality_of(:invoice_id) }

    it { should validate_presence_of(:subscription_id) }
    it { should validate_numericality_of(:subscription_id) }

    it { should validate_presence_of(:user_id) }
    it { should validate_numericality_of(:user_id) }

    it { should validate_presence_of(:manager_id) }
    it { should validate_numericality_of(:manager_id) }

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
