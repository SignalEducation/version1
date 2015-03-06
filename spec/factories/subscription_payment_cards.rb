# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string(255)
#  status              :string(255)
#  brand               :string(255)
#  last_4              :string(255)
#  expiry_month        :integer
#  expiry_year         :integer
#  address_line1       :string(255)
#  account_country     :string(255)
#  account_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string(255)
#  funding             :string(255)
#  cardholder_name     :string(255)
#  fingerprint         :string(255)
#  cvc_checked         :string(255)
#  address_line1_check :string(255)
#  address_zip_check   :string(255)
#  dynamic_last4       :string(255)
#  customer_guid       :string(255)
#  is_default_card     :boolean          default(FALSE)
#  address_line2       :string(255)
#  address_city        :string(255)
#  address_state       :string(255)
#  address_zip         :string(255)
#  address_country     :string(255)
#

FactoryGirl.define do
  factory :subscription_payment_card do
    user_id               1
    stripe_card_guid      'card_FACTORY-abc123'
    status                'card-live'
    brand                 'visa'
    last_4                '4242'
    expiry_month          1
    expiry_year           { Time.now.year + 1 }
    address_line1         '123 Fake Street'
    account_country       'Ireland'
    account_country_id    1
    stripe_object_name    'card'
    funding               'credit'
    cardholder_name       'Joe Cardholder'
    fingerprint           'ABC123'
    cvc_checked           true
    address_line1_check   false
    address_zip_check     false
    dynamic_last4         false
    customer_guid         'cus_ABC123'
    is_default_card       true
  end

end
