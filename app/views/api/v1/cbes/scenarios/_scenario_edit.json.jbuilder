# frozen_string_literal: true

json.id               scenario.id
json.name             scenario.name
json.content          scenario.content
json.section_id       scenario.cbe_section_id

json.questions scenario.questions.includes(:scenario, :answers).active do |question|
  json.partial! 'api/v1/cbes/questions/question_edit', locals: { question: question }
end

json.section_questions scenario.section.questions.includes(:scenario, :answers).active do |question|
  json.partial! 'api/v1/cbes/questions/question_edit', locals: { question: question }
end

if scenario.section.exhibits_scenario?
  json.exhibits scenario.exhibits.sort_by(&:sorting_order) do |exhibit|
    json.partial! 'api/v1/cbes/exhibits/exhibit', locals: { exhibit: exhibit }
  end

  json.requirements scenario.requirements.sort_by(&:sorting_order) do |requirement|
    json.partial! 'api/v1/cbes/requirements/requirement', locals: { requirement: requirement }
  end

  json.response_options scenario.response_options.sort_by(&:sorting_order) do |response_option|
    json.partial! 'api/v1/cbes/response_options/response_option', locals: { response_option: response_option }
  end
end
