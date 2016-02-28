class IntercomCourseStartedEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id, course_name)
    user = User.where(id: user_id).first
    intercom = Intercom::Client.new(
        app_id: ENV['intercom_app_id'],
        api_key: ENV['intercom_api_key']
    )

    event = intercom.events.create(
        :event_name => "Started Course",
        :created_at => Time.now.to_i,
        :email => user.email,
        :metadata => {
            "course_name" => course_name
        }
    )

    if event == nil
      intercom.events.create(
          :event_name => "Started Course",
          :created_at => Time.now.to_i,
          :user_id => user_id,
          :metadata => {
              "course_name" => course_name
          }
      )
    else
      return event
    end
  end

end
