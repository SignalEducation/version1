json.array! @sections do |section|
  json.partial! 'section', locals: { section: section }
end
