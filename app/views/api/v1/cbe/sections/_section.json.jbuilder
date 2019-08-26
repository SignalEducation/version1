json.id                   section.id
json.name                 section.name
json.scenario_description section.scenario_description
json.question_description section.question_description
json.scenario_label       section.scenario_label
json.question_label       section.question_label

json.cbe do
  json.name section.cbe.name
  json.description section.cbe.description
end

json.subject_course do
  json.name section.cbe.subject_course.name
end

json.exam_body do
  json.name section.cbe.subject_course.exam_body.name
end
