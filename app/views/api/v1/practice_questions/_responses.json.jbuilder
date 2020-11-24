json.responses practice_question.responses.order(:sorting_order) do |response|
  json.id                   response.id
  json.sorting_order        response.sorting_order
  json.kind                 response.kind
  json.content              response.content
  json.practice_question_id practice_question.id
end