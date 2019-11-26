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
end
