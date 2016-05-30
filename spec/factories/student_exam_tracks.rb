# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  latest_course_module_element_id :integer
#  exam_schedule_id                :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  session_guid                    :string
#  course_module_id                :integer
#  jumbo_quiz_taken                :boolean          default(FALSE)
#  percentage_complete             :float            default(0.0)
#  count_of_cmes_completed         :integer          default(0)
#  subject_course_id               :integer
#  count_of_questions_taken        :integer
#  count_of_questions_correct      :integer
#  count_of_quizzes_taken          :integer
#  count_of_videos_taken           :integer
#

FactoryGirl.define do
  factory :student_exam_track do
    user_id 1
    latest_course_module_element_id 1
    exam_schedule_id 1
  end

end
