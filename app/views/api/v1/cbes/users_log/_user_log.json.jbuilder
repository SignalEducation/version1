# frozen_string_literal: true

json.id     user_log.id
json.status user_log.status

json.user do
  json.id   user_log.user.id
  json.name user_log.user.name
end

json.answers user_log.answers do |answer|
  json.id      answer.id
  json.text    answer.content['text']
  json.correct answer.content['correct']
end

json.cbe do
  json.id user_log.cbe.id
  json.name user_log.cbe.name
  json.score user_log.cbe.score
  json.active user_log.cbe.active
end
