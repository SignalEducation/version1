class IntercomLessonStartedWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, course_name, module_name, type, lesson_name, wistia_id, quiz_score)
    user = User.where(id: user_id).first
    if user
      intercom = Intercom::Client.new(
          app_id: ENV['intercom_app_id'],
          api_key: ENV['intercom_api_key']
      )

      begin
        intercom_user = intercom.users.find(user_id: user_id)
      rescue Intercom::ResourceNotFound
        intercom_user = nil
      end

      if intercom_user
        intercom.events.create(
            :event_name => "Lesson Event",
            :created_at => Time.now.to_i,
            :user_id => user_id,
            :email => user.email,
            :metadata => {
                "lesson_name" => lesson_name,
                "lesson_type" => type,
                "module_name" => module_name,
                "course_name" => course_name,
                "vimeo_guid" => wistia_id,
                "quiz_score" => quiz_score
            }
        )
      end

    end
  end

end
