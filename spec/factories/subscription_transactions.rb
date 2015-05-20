# == Schema Information
#
# Table name: subscription_transactions
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  subscription_id              :integer
#  stripe_transaction_guid      :string
#  transaction_type             :string
#  amount                       :decimal(, )
#  currency_id                  :integer
#  alarm                        :boolean          default(FALSE), not null
#  live_mode                    :boolean          default(FALSE), not null
#  original_data                :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  subscription_payment_card_id :integer
#

FactoryGirl.define do
  factory :subscription_transaction do
    user_id                       1
    subscription_id               1
    stripe_transaction_guid       'tran_ABC123123123'
    currency_id                   1
    subscription_payment_card_id  1
    original_data                 { {some: 'value', data: 'present'} }
    factory :payment_transaction do
      transaction_type            'payment'
      amount                      19.95
      alarm                       false
    end

    factory :refund_transaction do
      transaction_type            'refund'
      amount                      -19.95
      alarm                       true
    end

    factory :failed_payment_transaction do
      transaction_type            'failed_payment'
      amount                      19.95
      alarm                       true
    end

  end

end
