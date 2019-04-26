# == Schema Information
#
# Table name: scenario_answer_attempts
#
#  id                               :integer          not null, primary key
#  scenario_question_attempt_id     :integer
#  user_id                          :integer
#  scenario_answer_template_id      :integer
#  original_answer_template_text    :text
#  user_edited_answer_template_text :text
#  editor_type                      :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  sorting_order                    :integer
#

FactoryBot.define do
  factory :scenario_answer_attempt do
    scenario_question_attempt_id { 1 }
    user_id { 1 }
    scenario_answer_template_id { 1 }
    original_answer_template_text { "MyText" }
    user_edited_answer_template_text { "MyText" }
    editor_type { "MyString" }
    sorting_order { 1 }
  end
end
