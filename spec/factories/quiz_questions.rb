# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string(255)
#  solution_to_the_question      :text
#  hints                         :text
#  created_at                    :datetime
#  updated_at                    :datetime
#

FactoryGirl.define do
  factory :quiz_question do
    course_module_element_quiz_id 1
    course_module_element_id 1
    difficulty_level 'easy'
    solution_to_the_question 'MyText'
    hints 'MyText'
  end

end
