# == Schema Information
#
# Table name: subscription_transactions
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  subscription_id              :integer
#  stripe_transaction_guid      :string(255)
#  transaction_type             :string(255)
#  amount                       :decimal(, )
#  currency_id                  :integer
#  alarm                        :boolean          default("false"), not null
#  live_mode                    :boolean          default("false"), not null
#  original_data                :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  subscription_payment_card_id :integer
#

require 'rails_helper'

describe SubscriptionTransaction do
  let(:subscription_transaction) { build(:subscription_transaction) }

  # Constants
  it { expect(SubscriptionTransaction.const_defined?(:TRANSACTION_TYPES)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should have_many(:invoices) }
  it { should belong_to(:subscription) }
  it { should belong_to(:subscription_payment_card) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:user_id) }

  it { should validate_presence_of(:subscription_id) }

  it { should validate_presence_of(:stripe_transaction_guid) }
  it { should validate_length_of(:stripe_transaction_guid).is_at_most(255) }

  it { should validate_inclusion_of(:transaction_type).in_array(SubscriptionTransaction::TRANSACTION_TYPES) }
  it { should validate_length_of(:transaction_type).is_at_most(255) }

  it { should validate_presence_of(:amount) }

  it { should validate_presence_of(:currency_id) }

  it { should validate_presence_of(:original_data) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubscriptionTransaction).to respond_to(:all_in_order) }
  it { expect(SubscriptionTransaction).to respond_to(:all_alarms) }

  # instance methods
  it { should respond_to(:destroyable?) }

  describe 'Methods' do
    before do
      allow_any_instance_of(StripeApiEvent).to receive(:get_data_from_stripe).and_return(true)
      allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
      allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
    end

    describe '#destroyable?' do
      it { expect(subscription_transaction.destroyable?).to be(true) }
    end
  end
end
