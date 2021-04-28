# frozen_string_literal: true

json.id             section.id
json.name           section.name
json.score          section.score
json.kind           section.kind
json.random         section.random
json.sorting_order  section.sorting_order
json.content        section.content

json.scenarios section.scenarios.active do |scenario|
  json.partial! 'api/v1/cbes/scenarios/scenario', locals: { scenario: scenario }
end

if section.random
  json.questions section.questions.includes(:scenario, :answers).active.shuffle do |question|
    json.partial! 'api/v1/cbes/questions/question', locals: { question: question }
  end
else
  json.questions section.questions.includes(:scenario, :answers).active.order(:sorting_order) do |question|
    json.partial! 'api/v1/cbes/questions/question', locals: { question: question }
  end
end
