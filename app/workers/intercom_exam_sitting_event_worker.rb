class IntercomExamSittingEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, exam_date, exam_body)
    user = User.where(id: user_id).first
    if user
      intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])

      intercom.events.create(
          :event_name => "ExamSitting #{exam_date}",
          :created_at => Time.now.to_i,
          :user_id => user_id,
          :email => user.email,
          :metadata => {
              "Exam Body" => exam_body
          }

      )
    end
  end

end
