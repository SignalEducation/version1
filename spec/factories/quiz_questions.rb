# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#  sorting_order                 :integer
#

FactoryGirl.define do
  factory :quiz_question do
    course_module_element_quiz_id 1
    course_module_element_id 1
    difficulty_level 'easy'
  end

end
