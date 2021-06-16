FactoryBot.define do
  factory :cbe_user_response, class: Cbe::UserResponse do
    score            { Faker::Number.between(from: 1.0, to: 10.0) }
    content          { Faker::Lorem.sentence }
    correct          { Faker::Boolean.boolean }
    educator_comment { Faker::Lorem.sentence }

    user_log            { build(:cbe_user_log) }
    cbe_response_option { build(:cbe_response_options) }
  end
end
