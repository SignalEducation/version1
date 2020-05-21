json.array! @courses do |course|
  json.value course.id
  json.text course.name
end
