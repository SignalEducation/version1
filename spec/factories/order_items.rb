# == Schema Information
#
# Table name: order_items
#
#  id                 :integer          not null, primary key
#  order_id           :integer
#  user_id            :integer
#  product_id         :integer
#  stripe_customer_id :string
#  price              :decimal(, )
#  currency_id        :integer
#  quantity           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :order_item do
    order_id 1
user_id 1
product_id 1
stripe_customer_id "MyString"
price "9.99"
currency_id 1
quantity 1
  end

end
