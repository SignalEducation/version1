json.array! @multiple_choice_questions do |multiple_choice_question|
  json.partial! 'multiple_choice_question', locals: { multiple_choice_question: multiple_choice_question }
end
