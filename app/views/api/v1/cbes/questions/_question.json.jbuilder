# frozen_string_literal: true

json.id               question.id
json.kind             question.kind
json.content          question.content
json.score            question.score
json.sorting_order    question.sorting_order
json.section_id       question.cbe_section_id

json.answers question.answers do |answer|
  if answer.blank?
    json.nil!
  else
    json.partial! 'api/v1/cbes/answers/answer', locals: { answer: answer }
  end
end

json.scenario do
  if question.scenario.nil?
    json.nil!
  else
    json.partial! 'api/v1/cbes/scenarios/scenario', locals: { scenario: question.scenario }
  end
end