FactoryBot.define do
  factory :cbe_section, class: Cbe::Section do
    scenario_description { Faker::Lorem.sentence }
    question_description { Faker::Lorem.sentence }
    scenario_label       { Faker::Lorem.word }
    question_label       { Faker::Lorem.word }
    name                 { Faker::Lorem.unique.word }

    trait :with_cbe do
      association :cbe, :with_subject_course
    end
  end
end
