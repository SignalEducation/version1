class MailchimpUpdateLessonWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id, lesson_name)
    MailchimpService.new.update_latest_lesson(user_id, lesson_name)
  end

end
