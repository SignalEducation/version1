# == Schema Information
#
# Table name: quiz_questions
#
#  id               :integer          not null, primary key
#  course_quiz_id   :integer
#  course_step_id   :integer
#  difficulty_level :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  destroyed_at     :datetime
#  course_id        :integer
#  sorting_order    :integer
#  custom_styles    :boolean          default("false")
#

FactoryBot.define do
  factory :quiz_question do
    course_quiz
    course_step
    difficulty_level { 'easy' }
    course
  end
end
