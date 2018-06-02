# == Schema Information
#
# Table name: scenario_answers
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  scenario_id              :integer
#  scenario_question_id     :integer
#  sorting_order            :integer
#  type                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryBot.define do
  factory :scenario_answers do
    course_module_element_id 1
    constructed_response_id 1
    scenario_id 1
    scenario_question_id 1
    sorting_order 1
    type 'text_editor'
  end
end
