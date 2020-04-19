# == Schema Information
#
# Table name: cbe_questions
#
#  id              :bigint           not null, primary key
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  kind            :integer
#  cbe_section_id  :bigint
#  score           :float
#  sorting_order   :integer
#  cbe_scenario_id :bigint
#  solution        :text
#  destroyed_at    :datetime
#  active          :boolean          default("true")
#
FactoryBot.define do
  factory :cbe_question, class: Cbe::Question do
    content  { Faker::Lorem.sentence }
    solution { Faker::Lorem.sentence }
    kind     { Cbe::Question.kinds.keys.sample }
    score    { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    sequence(:sorting_order)

    trait :with_section do
      association :section, :with_cbe, factory: :cbe_section
    end

    trait :with_scenario do
      association :scenario, :with_section, factory: :cbe_scenario
    end

    trait :with_answers do
      answers { build_list :cbe_answer, 3 }
    end
  end
end
