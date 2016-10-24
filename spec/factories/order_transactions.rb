# == Schema Information
#
# Table name: order_transactions
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  user_id          :integer
#  product_id       :integer
#  stripe_order_id  :string
#  stripe_charge_id :string
#  live_mode        :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :order_transaction do
    order_id 1
user_id 1
stripe_charge_id "MyString"
stripe_charge_id "MyString"
live_mode false
  end

end
