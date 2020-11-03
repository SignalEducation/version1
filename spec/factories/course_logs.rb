# == Schema Information
#
# Table name: course_logs
#
#  id                                    :integer          not null, primary key
#  user_id                               :integer
#  session_guid                          :string
#  course_id                             :integer
#  percentage_complete                   :integer          default("0")
#  count_of_cmes_completed               :integer          default("0")
#  latest_course_step_id                 :integer
#  completed                             :boolean          default("false")
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  count_of_questions_correct            :integer
#  count_of_questions_taken              :integer
#  count_of_videos_taken                 :integer
#  count_of_quizzes_taken                :integer
#  completed_at                          :datetime
#  count_of_constructed_responses_taken  :integer
#  count_of_notes_completed              :integer
#  count_of_practice_questions_completed :integer
#

FactoryBot.define do
  factory :course_log do
    user_id { 1 }
    session_guid { "MyString" }
    course_id { 1 }
    percentage_complete { 1 }
    latest_course_step_id { 1 }
    completed { false }

    association :course
  end
end
