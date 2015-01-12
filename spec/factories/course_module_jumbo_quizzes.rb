# == Schema Information
#
# Table name: course_module_jumbo_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_id                  :integer
#  name                              :string(255)
#  minimum_question_count_per_quiz   :integer
#  maximum_question_count_per_quiz   :integer
#  total_number_of_questions         :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  name_url                          :string(255)
#  best_possible_score_first_attempt :integer          default(0)
#  best_possible_score_retry         :integer          default(0)
#

FactoryGirl.define do
  factory :course_module_jumbo_quiz do
    course_module_id 1
    name 'My String'
    name_url 'my-string'
    minimum_question_count_per_quiz 1
    maximum_question_count_per_quiz 1
    total_number_of_questions 1
  end

end
