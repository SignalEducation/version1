json.array! @subject_courses do |subject_course|
  json.value subject_course.id
  json.text subject_course.name
end
