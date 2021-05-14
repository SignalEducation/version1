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
    cbe           = cbe_user_log.cbe
    total_scores  = cbe.exhibit_scenario? ? cbe.requirements.map(&:score).sum : cbe_user_log.questions.map(&:score).sum
    student_score = cbe_user_log.score

    "Total Score: #{student_score}/#{total_scores}"
  end

  def cbe_section_score(section_questions)
    total_scores  = section_questions.map { |q| q.cbe_question.score }.sum
    student_score = section_questions.map(&:score).sum

    "(#{student_score}/#{total_scores})"
  end

  def exercise_due_date(exercise)
    return '-' if exercise.submitted_on.nil?

    if exercise.autocorrected_cbe?
      exercise.submitted_on&.strftime('%d/%m/%y %H:%m')
    else
      (exercise.submitted_on + 3.days)&.strftime('%d/%m/%y %H:%m')
    end
  end
end
