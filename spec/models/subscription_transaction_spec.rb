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
#  alarm                        :boolean          default(FALSE), not null
#  live_mode                    :boolean          default(FALSE), not null
#  original_data                :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  subscription_payment_card_id :integer
#

require 'rails_helper'

describe SubscriptionTransaction do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  SubscriptionTransaction.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(SubscriptionTransaction.const_defined?(:TRANSACTION_TYPES)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  xit { should belong_to(:invoices) }
  it { should belong_to(:subscription) }
  it { should belong_to(:subscription_payment_card) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:subscription_id) }
  it { should validate_numericality_of(:subscription_id) }

  it { should validate_presence_of(:stripe_transaction_guid) }

  it { should validate_inclusion_of(:transaction_type).in_array(SubscriptionTransaction::TRANSACTION_TYPES) }

  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount) }

  it { should validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:currency_id) }

  it { should validate_presence_of(:original_data) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubscriptionTransaction).to respond_to(:all_in_order) }
  it { expect(SubscriptionTransaction).to respond_to(:all_alarms) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
