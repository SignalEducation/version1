json.id                       cbe.id
json.name                     cbe.name
json.title                    cbe.title
json.content                  cbe.content
json.exam_time                cbe.exam_time
json.hard_time_limit          cbe.hard_time_limit
json.number_of_pauses_allowed cbe.number_of_pauses_allowed
json.length_of_pauses         cbe.length_of_pauses
json.agreement_content        cbe.agreement_content
json.active                   cbe.active
json.score                    cbe.score

json.subject_course do
  json.name cbe.subject_course.name
  json.id cbe.subject_course.id
end

json.exam_body do
  json.name cbe.subject_course.exam_body.name
end
