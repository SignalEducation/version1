# frozen_string_literal: true

json.id                       cbe.id
json.name                     cbe.name
json.title                    cbe.title
json.content                  cbe.content
json.agreement_content        cbe.agreement_content
json.active                   cbe.active
json.score                    cbe.score
json.course_id                cbe.course.id
json.exhibits_scenario        cbe.has_exhibit_scenario?

json.introduction_pages cbe.introduction_pages.order(:sorting_order) do |page|
  json.id            page.id
  json.title         page.title
  json.content       page.content
  json.sorting_order page.sorting_order
end

json.resources cbe.resources.order(:sorting_order) do |resource|
  json.id            resource.id
  json.name          resource.name
  json.sorting_order resource.sorting_order
  json.file do
    json.name resource.document_file_name
    json.url  resource.document.url(:original, timestamp: false)
  end
end

json.sections cbe.sections.active.order(:sorting_order) do |section|
  json.partial! 'api/v1/cbes/sections/section', locals: { section: section }
end

json.scenarios cbe.scenarios do |scenario|
  json.partial! 'api/v1/cbes/scenarios/scenario', locals: { scenario: scenario }
end

json.questions cbe.questions.order(:sorting_order) do |question|
  json.partial! 'api/v1/cbes/questions/question', locals: { question: question }
end

json.course do
  json.name cbe.course.name
  json.id cbe.course.id
end

json.exam_body do
  json.name cbe.course.exam_body.name
end
