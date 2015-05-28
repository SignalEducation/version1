# == Schema Information
#
# Table name: question_banks
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  exam_level_id       :integer
#  number_of_questions :integer
#  easy_questions      :boolean          default(FALSE), not null
#  medium_questions    :boolean          default(FALSE), not null
#  hard_questions      :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :question_bank do
    user_id 1
    exam_level_id 1
    number_of_questions 1
    easy_questions false
    medium_questions false
    hard_questions false
  end

end
