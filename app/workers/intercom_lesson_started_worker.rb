class IntercomLessonStartedWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, course_name, module_name, type, lesson_name, video_id, quiz_score)

    IntercomNewLessonService.new({user_id: user_id, course_name: course_name, module_name: module_name,
                                  type: type, lesson_name: lesson_name, video_id: video_id, quiz_score: quiz_score}).perform

  end

end
