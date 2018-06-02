# == Schema Information
#
# Table name: scenario_questions
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  scenario_id              :integer
#  sorting_order            :integer
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryBot.define do
  factory :scenario_question do
    course_module_element_id 1
    constructed_response_id 1
    scenario_id 1
    sorting_order 1
    text_content 'MyString'
  end
end
