# == Schema Information
#
# Table name: course_module_element_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_element_id          :integer
#  name                              :string(255)
#  preamble                          :text
#  expected_time_in_seconds          :integer
#  time_limit_seconds                :integer
#  number_of_questions               :integer
#  question_selection_strategy       :string(255)
#  best_possible_score_first_attempt :integer
#  best_possible_score_retry         :integer
#  course_module_jumbo_quiz_id       :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#

FactoryGirl.define do
  factory :course_module_element_quiz do
    course_module_element_id 1
    name "MyString"
    preamble "MyText"
    expected_time_in_seconds 1
    time_limit_seconds 1
    number_of_questions 1
    question_selection_strategy "MyString"
    best_possible_score_first_attempt 1
    best_possible_score_retry 1
    course_module_jumbo_quiz_id 1
  end

end
