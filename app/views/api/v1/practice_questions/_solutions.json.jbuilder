json.solutions_v2 practice_question.solutions.order(:sorting_order) do |solution|
  json.id                   solution.id
  json.name                 solution.name
  json.sorting_order        solution.sorting_order
  json.kind                 solution.kind
  json.content              solution.content
  json.practice_question_id practice_question.id
end