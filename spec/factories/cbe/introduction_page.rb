FactoryBot.define do
  factory :cbe_introduction_page, class: Cbe::IntroductionPage do
    sorting_order  { Faker::Number.number(1) }
    content        { Faker::Lorem.sentence }
    title          { Faker::Lorem.word }

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end

    trait :with_cbe do
      association :cbe, :with_subject_course
    end
  end
end
