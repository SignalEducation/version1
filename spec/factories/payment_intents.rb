FactoryBot.define do
  factory :payment_intent do
    intent_id { "MyString" }
    client_secret { "MyString" }
    currency { "MyString" }
    next_action { "MyString" }
    payment_method_options { "MyString" }
    payment_method_types { "MyString" }
    receipt_email { "MyString" }
    status { "MyString" }
    amount { 1 }
    charges { "MyString" }
    data { "" }
  end
end
