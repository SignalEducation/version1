FactoryBot.define do
  factory :cbe_user_response, class: Cbe::UserResponse do
    score            { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    content          { Faker::Lorem.sentence }
    correct          { Faker::Boolean.boolean }
    educator_comment { Faker::Lorem.sentence }

    user_log            { build(:cbe_user_log) }
    cbe_response_option { build(:cbe_response_options) }
  end
end
