# frozen_string_literal: true

FactoryBot.define do
  factory :cbe_resource, class: Cbe::Resource do
    name     { Faker::Lorem.word }
    document { File.new(Rails.root.join('spec', 'support', 'fixtures', 'file.pdf')) }
    sequence(:sorting_order)
    association :cbe
  end
end
