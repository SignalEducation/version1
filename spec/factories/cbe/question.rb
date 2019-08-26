FactoryBot.define do
  factory :cbe_question, class: Cbe::Question do
    label       { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

    trait :with_section do
      association :section, :with_cbe, factory: :cbe_section
    end
  end
end
