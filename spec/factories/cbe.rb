FactoryBot.define do
  factory :cbe do
    sequence(:name)   { |n| "#{Faker::Lorem.word}-#{n}" }
    title             { Faker::Lorem.sentence }
    content           { Faker::Lorem.paragraph(sentence_count: 10) }
    agreement_content { Faker::Lorem.paragraph }
    score             { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    association :course

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
