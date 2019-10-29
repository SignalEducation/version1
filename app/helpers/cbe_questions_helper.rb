# frozen_string_literal: true

module CbeQuestionsHelper
  def user_answers_score(question, user_answers)
    if user_answers.map { |a| a.content['correct'] }.all?
      question.score
    else
      0
    end
  end
end
