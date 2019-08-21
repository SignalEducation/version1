json.array! @subject_courses do |subject_course|
  json.call(subject_course, :id, :name)
end
