FactoryBot.define do
  factory :key_area do
    sequence(:name) { |n| "#{Faker::Movies::LordOfTheRings.location} - #{n}" }
    active          { false }
    group

    trait :active do
      active { true }
    end
  end
end
