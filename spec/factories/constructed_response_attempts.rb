# == Schema Information
#
# Table name: constructed_response_attempts
#
#  id                                :integer          not null, primary key
#  constructed_response_id           :integer
#  scenario_id                       :integer
#  course_step_id                    :integer
#  course_step_log_id                :integer
#  user_id                           :integer
#  original_scenario_text_content    :text
#  user_edited_scenario_text_content :text
#  status                            :string
#  flagged_for_review                :boolean          default("false")
#  time_in_seconds                   :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  guid                              :string
#  scratch_pad_text                  :text
#

FactoryBot.define do

  factory :constructed_response_attempt do
    constructed_response_id { 1 }
    scenario_id { 1 }
    course_step_id { 1 }
    course_step_log_id { 1 }
    user_id { 1 }
    original_scenario_text_content { 'MyText' }
    user_edited_scenario_text_content { 'MyText' }
    status { 'Incomplete' }
    flagged_for_review { false }
    time_in_seconds { 1 }
    sequence(:guid)           { |n| "guid-#{n}" }
    scratch_pad_text { 'MyString' }
  end

end
