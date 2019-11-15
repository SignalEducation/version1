# frozen_string_literal: true

module OrdersHelper
  def order_name(order)
    if order.product.cbe?
      "#{order.product.cbe.name} Purchase"
    else
      "#{order.product.mock_exam.name} Purchase"
    end
  end

  def order_link(order)
    if order.product.cbe?
      exercise = order.exercises.first
      link_to exercise_path_by_state(exercise), target: '_blank' do
        'View'
      end
    else
      link_to order.product.mock_exam.file.url, target: '_blank' do
        'View'
      end
    end
  end

  def order_short_description(order)
    if order.product.mock_exam?
      'Purchase an ACCA Mock Exam and increase your chances of passing the ACCA exams.'
    elsif order.product.cbe?
      'WE NEED A SHORT DESCRIPTION HERE - - WE NEED A SHORT DESCRIPTION HERE - - WE NEED A SHORT DESCRIPTION HERE'
    else
      'Pass your ACCA exams faster with a question and solution correction pack.'
    end
  end

  def order_description(order)
    if order.product.mock_exam?
      'Purchase your Mock Exam today. Once submitted we will give you a solution paper, your result, question by question, personalised feedback on your exam and study topic recommendations.'
    elsif order.product.cbe?
      'WE NEED A DESCRIPTION HERE - - WE NEED A DESCRIPTION HERE  - - WE NEED A DESCRIPTION HERE'
    else
      'This correction pack is applicable to all ACCA courses. Pick and complete any ACCA question from any resource. Once you have submitted your work, our expert tutors will correct it and give you feedback within 3 days.'
    end
  end

  private

  def exercise_path_by_state(exercise)
    case exercise.state
    when 'pending'
      exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)
    when 'submitted', 'correcting', 'returned'
      exercise_path(exercise)
    end
  end
end
