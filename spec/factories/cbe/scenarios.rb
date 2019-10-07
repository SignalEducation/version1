FactoryBot.define do
  factory :cbe_scenario, class: Cbe::Scenario do
    name    { Faker::Lorem.word }
    content { Faker::Lorem.sentence }

    trait :with_section do
      association :section, :with_cbe, factory: :cbe_section
    end
  end
end
