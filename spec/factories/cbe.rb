FactoryBot.define do
  factory :cbe do
    name                      { Faker::Lorem.unique.word }
    title                     { Faker::Lorem.sentence }
    description               { Faker::Lorem.paragraph }

    trait :optional_settings do
      exam_time                 { Faker::Number.decimal }
      number_of_pauses_allowed  { Faker::Number.number(1) }
      length_of_pauses          { Faker::Number.number(2) }
      hard_time_limit           { Faker::Number.decimal }
    end

    trait :with_subject_course do
      association :subject_course
    end
  end
end
