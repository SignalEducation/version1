# frozen_string_literal: true

FactoryBot.define do
  factory :sub_category do
    sequence(:name)     { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:name_url) { |n| "#{Faker::Internet.slug}-#{n}" }
    description         { Faker::Lorem.paragraph(sentence_count: 10) }
    category            { Category.first || association(:category) }

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end

    trait :with_groups do
      groups { build_list :group, 5, category: category }
    end
  end
end
