FactoryGirl.define do
  factory :quiz_content do
    quiz_question_id 1
    quiz_answer_id 1
    text_content "MyText"
    contains_mathjax false
    contains_image false
    sorting_order 1
  end

end
