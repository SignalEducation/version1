FactoryBot.define do
  factory :cbe do
    sequence(:name)   { |n| "#{Faker::Lorem.word}-#{n}" }
    title             { Faker::Lorem.sentence }
    content           { Faker::Lorem.paragraph(sentence_count: 10) }
    agreement_content { Faker::Lorem.paragraph }
    score             { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    exam_time         { Faker::Number.decimal }

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end

    trait :optional_settings do
      number_of_pauses_allowed  { Faker::Number.number(1) }
      length_of_pauses          { Faker::Number.number(2) }
      hard_time_limit           { Faker::Number.decimal }
    end

    trait :with_subject_course do
      association :subject_course
    end
  end
end
