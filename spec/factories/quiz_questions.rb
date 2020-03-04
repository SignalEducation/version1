# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#  sorting_order                 :integer
#  custom_styles                 :boolean          default("false")
#

FactoryBot.define do
  factory :quiz_question do
    course_module_element_quiz
    course_module_element
    difficulty_level { 'easy' }
    subject_course
  end
end
