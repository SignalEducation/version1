# == Schema Information
#
# Table name: scenario_question_attempts
#
#  id                                 :integer          not null, primary key
#  constructed_response_attempt_id    :integer
#  user_id                            :integer
#  scenario_question_id               :integer
#  status                             :string
#  flagged_for_review                 :boolean          default("false")
#  original_scenario_question_text    :text
#  user_edited_scenario_question_text :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  sorting_order                      :integer
#

FactoryBot.define do
  factory :scenario_question_attempt do
    constructed_response_attempt_id { 1 }
    user_id { 1 }
    scenario_question_id { 1 }
    status { "Unseen" }
    flagged_for_review { false }
    original_scenario_question_text { "MyText" }
    user_edited_scenario_question_text { "MyText" }
  end
end
