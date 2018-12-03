# == Schema Information
#
# Table name: scenario_questions
#
#  id            :integer          not null, primary key
#  scenario_id   :integer
#  sorting_order :integer
#  text_content  :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  destroyed_at  :datetime
#

FactoryBot.define do
  factory :scenario_question do
    scenario_id 1
    sorting_order 1
    text_content 'MyString'
  end
end
