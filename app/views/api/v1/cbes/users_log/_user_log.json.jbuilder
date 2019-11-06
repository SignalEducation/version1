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

json.questions user_log.questions do |question|
  json.id      question.id
  json.score   question.score
  json.type    question.kind

  json.answers question.user_answers.where(cbe_user_log_id: user_log.id) do |answer|
    json.id             answer.id
    json.text           answer.content['text']
    json.correct        answer.content['correct']
  end
end
