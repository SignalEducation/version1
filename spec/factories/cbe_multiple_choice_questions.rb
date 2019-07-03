FactoryBot.define do
  factory :cbe_multiple_choice_question do
    label { "MyString" }
    is_correct_answer { false }
    cbe_question_grouping { nil }
    order { 1 }
  end
end
