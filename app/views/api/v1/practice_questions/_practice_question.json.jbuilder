# frozen_string_literal: true

json.id              practice_question.id
json.kind            practice_question.kind
json.name            practice_question.name
json.content         practice_question.content
json.course_step     practice_question.course_step
json.total_questions practice_question.questions.count
json.document do
  if practice_question.document.present?
    json.name practice_question.document_file_name
    json.url  practice_question.document.url(:original, timestamp: false)
  else
    json.nil!
  end
end

json.questions practice_question.questions.order(:sorting_order) do |question|
  json.id                   question.id
  json.sorting_order        question.sorting_order
  json.kind                 question.kind
  json.description          question.description
  json.content              question.content
  json.solution             question.solution
  json.practice_question_id practice_question.id

  answer = question.answers.find_by(course_step_log_id: step_log.id)
  json.answer_id      answer.id
  json.answer_content answer.content
end
