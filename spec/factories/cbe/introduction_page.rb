FactoryBot.define do
  factory :cbe_introduction_page, class: Cbe::IntroductionPage do
    content { Faker::Lorem.paragraph(sentence_count: rand(30..99)) }
    title   { Faker::Lorem.sentence }
    sequence(:sorting_order)

    trait :with_cbe do
      association :cbe, :with_subject_course
    end
  end
end
