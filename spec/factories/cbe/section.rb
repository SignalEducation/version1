FactoryBot.define do
  factory :cbe_section, class: Cbe::Section do
    name    { Faker::Lorem.word }
    content { Faker::Lorem.sentence }
    kind    { Cbe::Section.kinds.keys.sample }
    score   { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    sequence(:sorting_order)

    trait :with_cbe do
      association :cbe, :with_subject_course
    end
  end
end
