json.id               scenario.id
json.content          scenario.content

json.cbe_section do
  json.partial! 'api/v1/cbe/sections/section', locals: { section: scenario.section }
end
