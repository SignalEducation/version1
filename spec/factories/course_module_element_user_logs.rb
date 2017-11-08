# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                         :integer          not null, primary key
#  course_module_element_id   :integer
#  user_id                    :integer
#  session_guid               :string
#  element_completed          :boolean          default(FALSE), not null
#  time_taken_in_seconds      :integer
#  quiz_score_actual          :integer
#  quiz_score_potential       :integer
#  is_video                   :boolean          default(FALSE), not null
#  is_quiz                    :boolean          default(FALSE), not null
#  course_module_id           :integer
#  latest_attempt             :boolean          default(TRUE), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  seconds_watched            :integer          default(0)
#  count_of_questions_taken   :integer
#  count_of_questions_correct :integer
#  subject_course_id          :integer
#  student_exam_track_id      :integer
#  subject_course_user_log_id :integer
#

FactoryGirl.define do
  factory :course_module_element_user_log do
    course_module_element_id 1
    user_id 1
    session_guid "MyString"
    element_completed false
    time_taken_in_seconds 1
    quiz_score_actual 1
    quiz_score_potential 1
    is_video false
    is_quiz false
    course_module_id 1
    latest_attempt false
    count_of_questions_taken 1
    count_of_questions_correct 1
    subject_course_user_log_id 1
    subject_course_user_log_id 1
  end

end
