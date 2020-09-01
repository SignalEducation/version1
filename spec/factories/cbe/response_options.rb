# == Schema Information
#
# Table name: cbe_response_options
#
#  id              :bigint           not null, primary key
#  kind            :integer
#  quantity        :integer
#  sorting_order   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_scenario_id :bigint
#
FactoryBot.define do
  factory :cbe_response_options, class: Cbe::ResponseOption do
    kind     { Cbe::ResponseOption.kinds.keys.sample }
    quantity { 1 }
    sequence(:sorting_order)

    trait :with_scenario do
      association :scenario, :with_section, factory: :cbe_scenario
    end

    trait :with_user_responses do
      association :user_responses, factory: :cbe_user_response
    end
  end
end
