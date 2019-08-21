json.id                       cbe.id
json.name                     cbe.name
json.title                    cbe.title
json.description              cbe.description
json.exam_time                cbe.exam_time
json.hard_time_limit          cbe.hard_time_limit
json.number_of_pauses_allowed cbe.number_of_pauses_allowed
json.length_of_pauses         cbe.length_of_pauses

json.subject_course do
  json.name cbe.subject_course.name
end

json.exam_body do
  json.name cbe.subject_course.exam_body.name
end
