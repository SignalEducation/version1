# == Schema Information
#
# Table name: scenario_question_attempts
#
#  id                                 :integer          not null, primary key
#  constructed_response_attempt_id    :integer
#  course_module_element_user_log_id  :integer
#  user_id                            :integer
#  constructed_response_id            :integer
#  scenario_question_id               :integer
#  status                             :string
#  flagged_for_review                 :boolean          default(FALSE)
#  original_scenario_question_text    :text
#  user_edited_scenario_question_text :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#

FactoryBot.define do
  factory :scenario_question_attempt do
    constructed_response_attempt_id 1
    course_module_element_user_log_id 1
    user_id 1
    constructed_response_id 1
    scenario_question_id 1
    status "MyString"
    flagged_for_review false
    original_scenario_question_text "MyText"
    user_edited_scenario_question_text "MyText"
  end
end
