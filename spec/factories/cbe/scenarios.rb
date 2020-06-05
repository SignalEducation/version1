# == Schema Information
#
# Table name: cbe_scenarios
#
#  id             :bigint           not null, primary key
#  content        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cbe_section_id :bigint
#  name           :string
#  destroyed_at   :datetime
#  active         :boolean          default("true")
#
FactoryBot.define do
  factory :cbe_scenario, class: Cbe::Scenario do
    name    { Faker::Lorem.word }
    content { Faker::Lorem.sentence }

    trait :with_section do
      association :section, :with_cbe, factory: :cbe_section
    end
  end
end
