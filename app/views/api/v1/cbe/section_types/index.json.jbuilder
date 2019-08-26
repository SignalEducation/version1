json.array! @section_types do |section_type|
  json.call(section_type, :id, :name)
end
