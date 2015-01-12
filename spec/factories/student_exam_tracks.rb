# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  exam_level_id                   :integer
#  exam_section_id                 :integer
#  latest_course_module_element_id :integer
#  exam_schedule_id                :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  session_guid                    :string(255)
#  course_module_id                :integer
#  jumbo_quiz_taken                :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :student_exam_track do
    user_id 1
    exam_level_id 1
    exam_section_id 1
    latest_course_module_element_id 1
    exam_schedule_id 1
  end

end
