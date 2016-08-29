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
