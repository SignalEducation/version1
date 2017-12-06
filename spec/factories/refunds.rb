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
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :refund do
    stripe_guid "MyString"
charge_id 1
stripe_charge_guid "MyString"
invoice_id 1
subscription_id 1
user_id 1
manager_id 1
amount ""
reason "MyText"
status "MyString"
  end

end
