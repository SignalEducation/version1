# frozen_string_literal: true

json.array! @practice_questions do |practice_question|
  json.partial! 'practice_question', locals: { practice_question: practice_question }
end
