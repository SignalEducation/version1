# == Schema Information
#
# Table name: scenario_answer_templates
#
#  id                         :integer          not null, primary key
#  scenario_question_id       :integer
#  sorting_order              :integer
#  editor_type                :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  destroyed_at               :datetime
#  text_editor_content        :text
#  spreadsheet_editor_content :text
#

FactoryBot.define do
  factory :scenario_answer_templates do
    course_module_element_id 1
    constructed_response_id 1
    scenario_id 1
    scenario_question_id 1
    sorting_order 1
    text_content 'MyString'
    type 'text_editor'
  end
end
