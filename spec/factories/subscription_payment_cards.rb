# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string
#  status              :string
#  brand               :string
#  last_4              :string
#  expiry_month        :integer
#  expiry_year         :integer
#  address_line1       :string
#  account_country     :string
#  account_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string
#  funding             :string
#  cardholder_name     :string
#  fingerprint         :string
#  cvc_checked         :string
#  address_line1_check :string
#  address_zip_check   :string
#  dynamic_last4       :string
#  customer_guid       :string
#  is_default_card     :boolean          default(FALSE)
#  address_line2       :string
#  address_city        :string
#  address_state       :string
#  address_zip         :string
#  address_country     :string
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
