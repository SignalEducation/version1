# frozen_string_literal: true

json.id               scenario.id
json.name             scenario.name
json.content          scenario.content
json.section_id       scenario.cbe_section_id

json.questions scenario.questions do |question|
  json.partial! 'api/v1/cbes/questions/question_edit', locals: { question: question }
end
