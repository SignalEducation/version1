# frozen_string_literal: true

json.id              practice_question.id
json.kind            practice_question.kind
json.name            practice_question.name
json.content         practice_question.content
json.course_step     practice_question.course_step
json.total_questions practice_question.questions.count

json.questions practice_question.questions do |question|
  json.id            question.id
  json.sorting_order question.sorting_order
  json.kind          question.kind
  json.content       question.content
  json.solution      question.solution
end
