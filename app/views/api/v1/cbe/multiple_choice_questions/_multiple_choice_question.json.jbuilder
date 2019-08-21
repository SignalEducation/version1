json.id             multiple_choice_question.id
json.label          multiple_choice_question.label
json.order          multiple_choice_question.order
json.name           multiple_choice_question.name
json.question_1     multiple_choice_question.question_1
json.question_2     multiple_choice_question.question_2
json.question_3     multiple_choice_question.question_3
json.question_4     multiple_choice_question.question_4
json.correct_answer multiple_choice_question.correct_answer

json.cbe_section do
  json.partial! 'api/v1/cbe/sections/section', locals: { section: multiple_choice_question.cbe_section }
end
