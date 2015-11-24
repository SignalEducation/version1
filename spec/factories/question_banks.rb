# == Schema Information
#
# Table name: question_banks
#
#  id                          :integer          not null, primary key
#  question_selection_strategy :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  subject_course_id           :integer
#  number_of_questions         :integer
#  name                        :string
#  active                      :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :question_bank do
    question_selection_strategy 'random'
    subject_course_id 1
    number_of_questions 3
    name 'Final Exam Quiz'
    active true
  end
end
