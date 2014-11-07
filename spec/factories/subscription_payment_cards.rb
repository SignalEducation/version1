# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  stripe_card_guid   :string(255)
#  status             :string(255)
#  brand              :string(255)
#  last_4             :string(255)
#  expiry_month       :integer
#  expiry_year        :integer
#  billing_address    :string(255)
#  billing_country    :string(255)
#  billing_country_id :integer
#  account_email      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

FactoryGirl.define do
  factory :subscription_payment_card do
    user_id               1
    stripe_card_guid      'card_FACTORY-abc123'
    status                'live'
    brand                 'visa'
    last_4                '4242'
    expiry_month          1
    expiry_year           { Time.now.year + 1 }
    billing_address       '123 Fake Street'
    billing_country       'Ireland'
    billing_country_id    1
    account_email         'some.email@example.com'
  end

end
