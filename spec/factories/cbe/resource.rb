FactoryBot.define do
  factory :cbe_resource, class: Cbe::Resource do
    name     { Faker::Lorem.word }
    document { File.new(Rails.root.join('spec', 'support', 'fixtures', 'file.pdf')) }
    sequence(:sorting_order)

    trait :with_cbe do
      association :cbe, :with_subject_course
    end
  end
end
