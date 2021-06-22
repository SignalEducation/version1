# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_requirements
#
#  id              :bigint           not null, primary key
#  name            :string
#  content         :text
#  score           :float
#  sorting_order   :integer
#  kind            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_scenario_id :bigint
#  solution        :text
#
FactoryBot.define do
  factory :cbe_requirements, class: Cbe::Requirement do
    name     { Faker::Lorem.word }
    kind     { Cbe::Requirement.kinds.keys.sample }
    score    { Faker::Number.between(from: 1.0, to: 10.0) }
    content  { Faker::Lorem.sentence }
    solution { Faker::Lorem.sentence }
    sequence(:sorting_order)

    trait :with_scenario do
      association :scenario, :with_section, factory: :cbe_scenario
    end
  end
end
