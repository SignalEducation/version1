# == Schema Information
#
# Table name: scenario_answer_attempts
#
#  id                                :integer          not null, primary key
#  scenario_question_attempt_id      :integer
#  constructed_response_attempt_id   :integer
#  course_module_element_user_log_id :integer
#  user_id                           :integer
#  scenario_question_id              :integer
#  constructed_response_id           :integer
#  scenario_answer_template_id       :integer
#  original_answer_template_text     :text
#  user_edited_answer_template_text  :text
#  editor_type                       :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

FactoryBot.define do
  factory :scenario_answer_attempt do
    scenario_question_attempt_id 1
    constructed_response_attempt_id 1
    course_module_element_user_log_id 1
    user_id 1
    scenario_question_id 1
    constructed_response_id 1
    scenario_answer_template_id 1
    original_answer_template_text "MyText"
    user_edited_answer_template_text "MyText"
    editor_type "MyString"
  end
end
