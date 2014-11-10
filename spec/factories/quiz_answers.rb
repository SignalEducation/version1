# == Schema Information
#
# Table name: quiz_answers
#
#  id                            :integer          not null, primary key
#  quiz_question_id              :integer
#  correct                       :boolean          default(FALSE), not null
#  degree_of_wrongness           :string(255)
#  wrong_answer_explanation_text :text
#  wrong_answer_video_id         :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#

FactoryGirl.define do
  factory :quiz_answer do
    quiz_question_id 1
    correct false
    degree_of_wrongness "MyString"
    wrong_answer_explanation_text "MyText"
    wrong_answer_video_id 1
  end

end
