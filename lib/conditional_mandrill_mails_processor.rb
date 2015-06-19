class ConditionalMandrillMailsProcessor
  DAYS_IN_A_ROW = 9

  # Sends 'Study Streak' mail to all students that have worked on one ExamLevel
  # or ExamSection for 9 days in a row (and haven't finished it yet).
  def self.process_study_streak(start_calculation_from)
    last_log_date = start_calculation_from == 'today' ? Time.now.end_of_day : 1.day.ago.end_of_day
    # Get all users with exam track created on starting date. Exam track
    # that is kept is the last updated one, so we have hash with student
    # ids as keys and single student exam track as value.
    sets = StudentExamTrack
           .where("user_id is not null")
           .where("percentage_complete < 100")
           .where("updated_at >= ? and updated_at <= ?", last_log_date.beginning_of_day, last_log_date.end_of_day)
           .order("user_id asc, updated_at desc")
           .group_by { |set| set.user_id }
           .each_with_object({}) { |(k, v), h| h[k] = v[0] }
    sets.each do |student_id, student_exam_track|
      # Pick up all course module ids with given section_id or exam_level_id
      # (if section_id is null).
      course_module_ids = student_exam_track.exam_section_id ?
                         CourseModule.where(exam_section_id: student_exam_track.exam_section_id).pluck(:id) :
                            CourseModule.where(exam_level_id: student_exam_track.exam_level_id).pluck(:id)
      # Now get all element ids wor all course modules so we can extract
      # related course module element user logs.
      course_module_element_ids = CourseModuleElement.where(course_module_id: course_module_ids).pluck(:id)

      # This is preliminary filter. If user does not have at least 9 logs he certainly
      # is not candidate for Study Streak mail because this mail is sent if user has worked
      # on one exam section or exam level for nine days in a row.
      if CourseModuleElementUserLog.where(user_id: student_id, course_module_element_id: course_module_element_ids).count >= DAYS_IN_A_ROW
        # We are grouping logs by date. Only users that have nine keys
        # are candidate (additional condition will be that hey are 9
        # days in a row)
        cme_user_logs = CourseModuleElementUserLog
                        .where(user_id: student_id, course_module_element_id: course_module_element_ids)
                        .group_by { |cmeul| cmeul.updated_at.to_date }
        # Take pair of keys, calculate difference and finally take last DAYS_IN_A_ROW elements
        # and calculate unique values which must all be 1 (days in a row requirement).
        log_distances = cme_user_logs.keys.sort.each_cons(2).map { |a, b| (b - a).to_i }[-DAYS_IN_A_ROW..-1]
        if log_distances && log_distances.uniq.length == 1 && log_distances.uniq[0] == 1 &&
          cme_user_logs.keys.length >= DAYS_IN_A_ROW &&
          cme_user_logs[last_log_date.to_date]
          MandrillWorker.perform_at(student_exam_track.updated_at + 12.hours, student_id, 'send_study_streak_email',
                                    course_special_link(student_exam_track.latest_course_module_element.next_element))
        end
      end
    end
  end
end
