json.id               question.id
json.kind             question.kind
json.content          question.content
json.score            question.score

json.cbe_section do
  json.partial! 'api/v1/cbe/sections/section', locals: { section: question.section }
end
