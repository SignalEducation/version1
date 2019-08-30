json.id             section.id
json.name           section.name
json.score          section.score
json.kind           section.kind
json.sorting_order  section.sorting_order
json.content        section.content

json.questions section.questions.order(:sorting_order) do |question|
  json.partial! 'api/v1/cbe/questions/question', locals: { question: question }
end
