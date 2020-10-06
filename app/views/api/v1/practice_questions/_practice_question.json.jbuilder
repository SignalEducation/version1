# frozen_string_literal: true

json.id          practice_question.id
json.kind        practice_question.kind
json.name        practice_question.name
json.content     practice_question.content
json.course_step practice_question.course_step

json.answers practice_question.answers do |answer|
  json.id            answer.id
  json.sorting_order answer.sorting_order
  json.kind          answer.kind
  json.content       answer.content
  json.solution      answer.solution
end
