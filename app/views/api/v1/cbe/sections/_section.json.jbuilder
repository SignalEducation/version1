json.id             section.id
json.name           section.name
json.score          section.score
json.kind           section.kind
json.sorting_order  section.sorting_order
json.content        section.content

json.cbe do
  json.name section.cbe.name
  json.content section.cbe.content
end

json.subject_course do
  json.name section.cbe.subject_course.name
end

json.exam_body do
  json.name section.cbe.subject_course.exam_body.name
end
