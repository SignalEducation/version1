# == Schema Information
#
# Table name: course_module_element_quizzes
#
#  id                          :integer          not null, primary key
#  course_module_element_id    :integer
#  number_of_questions         :integer
#  question_selection_strategy :string
#  created_at                  :datetime
#  updated_at                  :datetime
#  destroyed_at                :datetime
#

FactoryGirl.define do
  factory :course_module_element_quiz do
    course_module_element_id 1
    number_of_questions 1
    question_selection_strategy 'random'
  end

end
