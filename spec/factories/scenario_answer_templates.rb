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
  factory :scenario_answer_template do
    scenario_question_id { 1 }
    sorting_order { 1 }
    editor_type { 'text_editor' }
    text_editor_content { 'MyString' }
    spreadsheet_editor_content { 'MyString' }
  end
end
