# frozen_string_literal: true

module ExercisesHelper
  def pending_exercise_message(exercise)
    if exercise.product.mock_exam?
      'Start your mock exam'
    elsif exercise.product.cbe?
      'Start your CBE session'
    else
      'Submit your questions & answers work for correction'
    end
  end

  def cbe_score(cbe_user_log)
    total_scores  = cbe_user_log.questions.map { |q| q.cbe_question.score }.sum
    student_score = cbe_user_log.score

    "Total Score: #{student_score}/#{total_scores}"
  end

  def cbe_section_score(section_questions)
    total_scores  = section_questions.map { |q| q.cbe_question.score }.sum
    student_score = section_questions.map(&:score).sum

    "(#{student_score}/#{total_scores})"
  end
end
