# == Schema Information
#
# Table name: question_banks
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  exam_level_id               :integer
#  easy_questions              :integer
#  medium_questions            :integer
#  hard_questions              :integer
#  question_selection_strategy :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

FactoryGirl.define do
  factory :question_bank do
    user_id 1
    exam_level_id 1
    easy_questions 1
    medium_questions 1
    hard_questions 1
    question_selection_strategy 'random'
  end

end
