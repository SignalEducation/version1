# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  latest_course_module_element_id      :integer
#  created_at                           :datetime
#  updated_at                           :datetime
#  session_guid                         :string
#  course_module_id                     :integer
#  percentage_complete                  :float            default(0.0)
#  count_of_cmes_completed              :integer          default(0)
#  subject_course_id                    :integer
#  count_of_questions_taken             :integer
#  count_of_questions_correct           :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  subject_course_user_log_id           :integer
#  count_of_constructed_responses_taken :integer
#  course_section_id                    :integer
#  course_section_user_log_id           :integer
#

FactoryBot.define do
  factory :student_exam_track do
    user_id 1
    latest_course_module_element_id 1
    subject_course_id 1
    subject_course_user_log_id 1
  end

end
