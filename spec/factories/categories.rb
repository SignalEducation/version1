# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name)     { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:name_url) { |n| "#{Faker::Internet.slug}-#{n}" }
    description         { Faker::Lorem.paragraph(sentence_count: 10) }

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end

    trait :with_sub_categories do
      sub_categories { build_list :sub_category, 5 }
    end

    trait :with_groups do
      groups { build_list :group, 5 }
    end
  end
end
