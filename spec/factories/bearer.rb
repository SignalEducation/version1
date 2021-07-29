FactoryBot.define do
  factory :bearer do
    name    { Faker::Company.name }
    slug    { Faker::Internet.slug }
    api_key { Faker::Crypto.md5 }

    trait :active do
      status { :active }
    end

    trait :inactive do
      status { :inactive }
    end
  end
end
