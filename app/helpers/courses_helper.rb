# frozen_string_literal: true

module CoursesHelper
  def course_lesson_status(course_lesson, exam_tracks, completed_ids)
    exam_tracks && completed_ids.include?(course_lesson.id) ? 'completed' : ''
  end

  def course_element_user_log_status(log)
    return '' if log.nil?

    log.is_quiz? ? quiz_status(log) : course_status(log)
  end

  private

  def quiz_status(log)
    log.quiz_result
  end

  def course_status(log)
    log.element_completed ? 'completed' : 'started'
  end
end
