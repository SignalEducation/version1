# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                         :integer          not null, primary key
#  course_module_element_id   :integer
#  user_id                    :integer
#  session_guid               :string(255)
#  element_completed          :boolean          default("false"), not null
#  time_taken_in_seconds      :integer
#  quiz_score_actual          :integer
#  quiz_score_potential       :integer
#  is_video                   :boolean          default("false"), not null
#  is_quiz                    :boolean          default("false"), not null
#  course_module_id           :integer
#  latest_attempt             :boolean          default("true"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  seconds_watched            :integer          default("0")
#  count_of_questions_taken   :integer
#  count_of_questions_correct :integer
#  subject_course_id          :integer
#  student_exam_track_id      :integer
#  subject_course_user_log_id :integer
#  is_constructed_response    :boolean          default("false")
#  preview_mode               :boolean          default("false")
#  course_section_id          :integer
#  course_section_user_log_id :integer
#

FactoryBot.define do
  factory :course_module_element_user_log do
    course_module_element_id { 1 }
    user_id { 1 }
    session_guid { "MyString" }
    element_completed { false }
    time_taken_in_seconds { 1 }
    quiz_score_actual { 1 }
    quiz_score_potential { 1 }
    is_video { false }
    is_quiz { false }
    course_module_id { 1 }
    latest_attempt { false }
    count_of_questions_taken { 1 }
    count_of_questions_correct { 1 }
    subject_course_user_log_id { 1 }


    factory :quiz_cmeul do
      is_quiz { true }
    end

    factory :video_cmeul do
      is_video { true }
    end

    factory :cr_cmeul do
      is_constructed_response { true }
    end

  end

end
