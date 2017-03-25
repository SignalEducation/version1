class CronTasks

  def self.process_student_exam_tracks

    all_course_modules = CourseModule.all_active

    all_course_modules.each do |cm|
      time_now = Proc.new { Time.now }.call
      if cm.updated_at > time_now - 7.days
        cm.student_exam_tracks.each do |set|
          StudentExamTracksWorker.perform_async(set.id)
        end
        SubjectCourseUserLogWorker.perform_at(5.minute.from_now, cm.subject_course_id)
      end
    end
  end

  def self.pause_inactive_enrollments

    all_enrollments = Enrollment.all_active

    all_enrollments.each do |enrollment|
      time_now = Proc.new { Time.now }.call
      if enrollment.updated_at < time_now - 6.months
        enrollment.update_attribute(:active, false)
      end
    end
  end

  def self.check_for_expiring_cards

    all_default_cards = SubscriptionPaymentCard.all_default_cards.all_in_order

    all_default_cards.each do |card|
      if card.expiring_soon?
        MandrillWorker.perform_async(self.user_id, 'send_card_expiring_soon_email', Rails.application.routes.url_helpers.account_url(locale: 'en', host: 'www.learnsignal.com'))
      end
    end
  end

end
