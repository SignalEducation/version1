class ConditionalMandrillMailsProcessor
  class << self
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  DAYS_IN_A_ROW = 9
  DAYS_WITHOUT_UPDATE = 3

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
      course_module_ids = CourseModule.where(subject_course_id: student_exam_track.subject_course_id).pluck(:id)
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
        # Take pair of keys, calculate difference and finally take last DAYS_IN_A_ROW - 1 elements
        # (we are taking paris so we have one less than requested days) and calculate unique values
        # which must all be 1 (days in a row requirement).
        log_distances = cme_user_logs.keys.sort.each_cons(2).map { |a, b| (b - a).to_i }[-(DAYS_IN_A_ROW - 1)..-1]
        if log_distances && log_distances.uniq.length == 1 && log_distances.uniq[0] == 1 &&
          cme_user_logs.keys.length >= DAYS_IN_A_ROW &&
          cme_user_logs[last_log_date.to_date]
          if student_exam_track.latest_course_module_element &&
             !student_exam_track.latest_course_module_element.next_element.nil?
            url = url_helpers.edit_course_module_element_url(id: student_exam_track.latest_course_module_element.next_element.id,
                                                             host: Rails.env.test? ? "www.example.com" : Rails.application.routes.default_url_options[:host])
            MandrillWorker.perform_at(student_exam_track.updated_at + 12.hours,
                                      student_id, 'send_study_streak_email',
                                      url) if url
          end
        end
      end
    end
  end

  def self.process_we_havent_seen_you_in_a_while

    course_logs = SubjectCourseUserLog.where("updated_at > ? and updated_at < ?", DAYS_WITHOUT_UPDATE.days.ago.beginning_of_day, DAYS_WITHOUT_UPDATE.days.ago.end_of_day).where("percentage_complete < 100").order("updated_at desc")

    course_logs.each do |log|
      if log.enrollment
        course_name = log.subject_course.name
        days = DAYS_WITHOUT_UPDATE
        course_parent_url = log.subject_course.subject_course_category == SubjectCourseCategory.default_subscription_category ? 'subscription_course' : 'product_course'
        url = Rails.application.routes.default_url_options[:host] + "/#{course_parent_url}/#{log.subject_course.name_url}"
        MandrillWorker.perform_async(log.user.id, "send_we_havent_seen_you_in_a_while_email", url, course_name, days) if log
      end
    end
  end

  def self.process_free_trial_ended_notifications
    individual_user_group = UserGroup.default_student_user_group
    free_trial_student_type = StudentUserType.default_free_trial_user_type
    free_and_product_student_type = StudentUserType.default_free_trial_and_product_user_type

    free_trial_users = User.where(free_trial: true).where(
        user_group_id: individual_user_group.id).where(
        student_user_type_id: free_trial_student_type.id)

    free_trial_product_users = User.where(free_trial: true).where(
        user_group_id: individual_user_group.id).where(
        student_user_type_id: free_and_product_student_type.id)

    users = free_trial_product_users + free_trial_users


    users.each do |user|
      if !user.subscriptions.any? &&
         !user.days_or_seconds_valid? &&
         user.trial_ended_notification_sent_at.nil? &&
         user.active?


        if user.student_user_type_id == StudentUserType.default_free_trial_user_type.id
          new_user_type_id = StudentUserType.default_no_access_user_type.id
        elsif user.student_user_type_id == StudentUserType.default_free_trial_and_product_user_type.id
          new_user_type_id = StudentUserType.default_product_user_type.id
        else
          new_user_type_id = user.student_user_type_id
        end

        user.update_attributes(free_trial: false, trial_ended_notification_sent_at: Time.now, student_user_type_id: new_user_type_id)
      end
    end
  end
end
