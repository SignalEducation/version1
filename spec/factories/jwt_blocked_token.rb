FactoryBot.define do
  factory :jwt_blocked_token do
    token { Faker::Crypto.md5 }
  end
end
