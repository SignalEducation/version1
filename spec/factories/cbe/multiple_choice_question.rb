FactoryBot.define do
  factory :cbe_multiple_choice_question, class: Cbe::MultipleChoiceQuestion do
    name           { Faker::Lorem.sentence }
    description    { Faker::Lorem.sentence }
    label          { Faker::Lorem.word }
    order          { Faker::Number.number(1) }
    question_1     { Faker::Lorem.sentence }
    question_2     { Faker::Lorem.sentence }
    question_3     { Faker::Lorem.sentence }
    question_4     { Faker::Lorem.sentence }
    correct_answer { Faker::Number.number(1) }

    trait :is_correct do
      is_correct_answer { true }
    end

    trait :is_incorrect do
      is_correct_answer { false }
    end

    trait :with_cbe_section do
      association :cbe_section, :with_cbe
    end
  end
end
