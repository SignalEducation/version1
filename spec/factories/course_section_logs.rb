# == Schema Information
#
# Table name: course_section_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  course_section_id                    :integer
#  course_log_id                        :integer
#  latest_course_step_id                :integer
#  percentage_complete                  :float
#  count_of_cmes_completed              :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  course_id                            :integer
#  count_of_constructed_responses_taken :integer
#  count_of_notes_taken                 :integer
#  count_of_practice_questions_taken    :integer
#

FactoryBot.define do
  factory :course_section_log do
    user_id { 1 }
    latest_course_step_id { 1 }
    course_section_id { 1 }
    percentage_complete { 1.5 }
    count_of_cmes_completed { 1 }
    course_log_id { 1 }
    count_of_quizzes_taken { 1 }
    count_of_videos_taken { 1 }
  end
end
