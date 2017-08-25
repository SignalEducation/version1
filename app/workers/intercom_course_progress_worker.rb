class IntercomCourseProgressEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, course_name, percentage_complete)
    user = User.where(id: user_id).first
    if user
      intercom = Intercom::Client.new(
          app_id: ENV['intercom_app_id'],
          api_key: ENV['intercom_api_key']
      )

      intercom.events.create(
          :event_name => "#{percentage_complete} Achieved - #{course_name}",
          :created_at => Time.now.to_i,
          :user_id => user_id,
          :email => user.email
      )
    end
  end

end
