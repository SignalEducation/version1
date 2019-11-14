# frozen_string_literal: true

json.id     user_log.id
json.status user_log.status
json.score  user_log.score

json.user do
  json.id   user_log.user.id
  json.name user_log.user.name
end

json.cbe do
  json.id user_log.cbe.id
  json.name user_log.cbe.name
  json.active user_log.cbe.active
end

json.user_questions user_log.questions do |user_question|
  json.id      user_question.id
  json.score   user_question.score
  json.correct user_question.correct

  json.user_answers user_question.answers do |user_answer|
    json.id             user_answer.id
    json.text           user_answer.content['text']
    json.correct        user_answer.content['correct']
  end
end
