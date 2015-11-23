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
#

FactoryGirl.define do
  factory :question_bank do
    user_id 1
    exam_level_id 1
    easy_questions 1
    medium_questions 1
    hard_questions 1
    question_selection_strategy 'random'
    subject_course_id 1
  end

end
