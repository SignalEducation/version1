FactoryGirl.define do
  factory :corporate_group do
    corporate_customer_id 1
    sequence(:name) { |n| "Corporate Group #{n}" }
  end
end
