# frozen_string_literal: true

module OrdersHelper
  def order_link(order)
    if order.product.cbe? && order.exercises.present?
      exercise = order.exercises.first
      link_to exercise_path_by_state(exercise), target: '_blank' do
        'View'
      end
    elsif order.product&.mock_exam
      link_to order.product.mock_exam.file.url, target: '_blank' do
        'View'
      end
    end
  end

  def order_heading(order)
    order.product.payment_heading.presence || "#{order.product.name_by_type} Purchase"
  end

  def order_short_description(order)
    if order.product.payment_subheading.present?
      order.product.payment_subheading
    elsif order.product.mock_exam?
      'Purchase a Mock Exam and increase your chances of passing the your exams.'
    elsif order.product.cbe?
      'Purchase a CBE and increase your chances of passing your exams.'
    else
      'Pass your exams faster with a question and solution correction pack.'
    end
  end

  def order_description(order)
    if order.product.payment_description.present?
      order.product.payment_description
    elsif order.product.mock_exam?
      'Purchase your Mock Exam today. Once submitted we will give you a solution paper, your result, question by question, personalised feedback on your exam and study topic recommendations within 3 days.'
    elsif order.product.cbe?
      'Purchase your CBE today to start practicing for your online exam by simulating the computer based exam on the learnsignal site.'
    else
      'This correction pack is applicable to all courses. Pick and complete any question from any resource. Once you have submitted your work, our expert tutors will correct it and give you feedback within 3 days.'
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
