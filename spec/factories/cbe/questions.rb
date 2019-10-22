FactoryBot.define do
  factory :cbe_question, class: Cbe::Question do
    content  { Faker::Lorem.sentence }
    solution { Faker::Lorem.sentence }
    kind     { Cbe::Question.kinds.keys.sample }
    score    { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    sequence(:sorting_order)

    trait :with_section do
      association :section, :with_cbe, factory: :cbe_section
    end

    trait :with_scenario do
      association :scenario, :with_section, factory: :cbe_scenario
    end

    trait :with_answers do
      answers { build_list :cbe_answer, 3 }
    end
  end
end
