FactoryGirl.define do
  factory :quiz_question do
    course_module_element_quiz_id 1
    course_module_element_id 1
    difficulty_level "MyString"
    solution_to_the_question "MyText"
    hints "MyText"
  end

end
