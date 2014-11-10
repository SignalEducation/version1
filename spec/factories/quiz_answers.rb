FactoryGirl.define do
  factory :quiz_answer do
    quiz_question_id 1
    correct false
    degree_of_wrongness "MyString"
    wrong_answer_explanation_text "MyText"
    wrong_answer_video_id 1
  end

end
