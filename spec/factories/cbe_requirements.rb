# == Schema Information
#
# Table name: cbe_requirements
#
#  id              :bigint           not null, primary key
#  name            :string
#  content         :string
#  score           :float
#  sorting_order   :integer
#  kind            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_section_id  :bigint
#  cbe_scenario_id :bigint
#
FactoryBot.define do
  factory :cbe_requirement do
    
  end
end
