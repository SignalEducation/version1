# == Schema Information
#
# Table name: course_lesson_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  latest_course_step_id                :integer
#  created_at                           :datetime
#  updated_at                           :datetime
#  session_guid                         :string(255)
#  course_lesson_id                     :integer
#  percentage_complete                  :float            default("0.0")
#  count_of_cmes_completed              :integer          default("0")
#  course_id                            :integer
#  count_of_questions_taken             :integer
#  count_of_questions_correct           :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  course_log_id                        :integer
#  count_of_constructed_responses_taken :integer
#  course_section_id                    :integer
#  course_section_log_id                :integer
#  count_of_notes_taken                 :integer
#

FactoryBot.define do
  factory :course_lesson_log do
    user_id { 1 }
    latest_course_step_id { 1 }
    course_id { 1 }
    course_log_id { 1 }
    course_lesson
    course_section
    course
  end

end
