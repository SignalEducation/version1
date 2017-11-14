class IntercomCourseEnrolledEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, course_name, exam_date)
    user = User.where(id: user_id).first
    if user
      intercom = Intercom::Client.new(
          app_id: ENV['INTERCOM_APP_ID'],
          api_key: ENV['INTERCOM_API_KEY']
      )

      intercom.events.create(
          :event_name => "#{course_name} Enrolled",
          :created_at => Time.now.to_i,
          :user_id => user_id,
          :email => user.email,
          :meta_data => {
              'ExamSitting Date' => exam_date
          }
      )
    end
  end

end
