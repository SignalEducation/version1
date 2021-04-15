# frozen_string_literal: true

json.id     user_log.id
json.status user_log.status
json.score  user_log.score
json.agreed user_log.agreed

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
  json.id              user_question.cbe_question_id
  json.score           user_question.score
  json.correct         user_question.correct
  json.cbe_question_id user_question.cbe_question_id

  json.answers_attributes user_question.answers do |user_answer|
    json.cbe_answer_id user_answer.cbe_answer_id

    if user_question.cbe_question.spreadsheet?
      json.content user_answer.content
    else
      json.content do
        json.text    user_answer.content['text']
        json.correct user_answer.content['correct']
      end
    end
  end
end

json.user_responses user_log.responses do |user_response|
  json.id                     user_response.id
  json.content                user_response.content
  json.cbe_response_option_id user_response.cbe_response_option_id
end
