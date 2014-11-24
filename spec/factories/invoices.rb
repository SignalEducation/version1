# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  corporate_customer_id       :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  unit_price_ex_vat           :decimal(, )
#  line_total_ex_vat           :decimal(, )
#  vat_rate_id                 :integer
#  line_total_vat_amount       :decimal(, )
#  line_total_inc_vat          :decimal(, )
#  created_at                  :datetime
#  updated_at                  :datetime
#

FactoryGirl.define do
  factory :invoice do
    user_id 1
corporate_customer_id 1
subscription_transaction_id 1
subscription_id 1
number_of_users 1
currency_id 1
unit_price_ex_vat "9.99"
line_total_ex_vat "9.99"
vat_rate_id 1
line_total_vat_amount "9.99"
line_total_inc_vat "9.99"
  end

end
