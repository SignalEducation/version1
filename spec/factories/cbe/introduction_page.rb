FactoryBot.define do
  factory :cbe_introduction_page, class: Cbe::IntroductionPage do
    content { Faker::Lorem.sentence }
    title   { Faker::Lorem.word }
    sequence(:sorting_order)

    trait :with_cbe do
      association :cbe, :with_subject_course
    end
  end
end
