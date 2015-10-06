# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                          :integer          not null, primary key
#  course_module_element_id    :integer
#  user_id                     :integer
#  session_guid                :string
#  element_completed           :boolean          default(FALSE), not null
#  time_taken_in_seconds       :integer
#  quiz_score_actual           :integer
#  quiz_score_potential        :integer
#  is_video                    :boolean          default(FALSE), not null
#  is_quiz                     :boolean          default(FALSE), not null
#  course_module_id            :integer
#  latest_attempt              :boolean          default(TRUE), not null
#  corporate_customer_id       :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  course_module_jumbo_quiz_id :integer
#  is_jumbo_quiz               :boolean          default(FALSE), not null
#  seconds_watched             :integer          default(0)
#  is_question_bank            :boolean          default(FALSE), not null
#  question_bank_id            :integer
#  count_of_questions_taken    :integer
#  count_of_questions_correct  :integer
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
    corporate_customer_id 1
    course_module_jumbo_quiz_id 1
    is_jumbo_quiz false
  end

end
