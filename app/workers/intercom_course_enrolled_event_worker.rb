class IntercomCourseEnrolledEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, course_name, exam_date)
    intercom = InitializeIntercomClientService.new().perform

    @user = User.where(id: user_id).first

    if @user
      intercom.events.create(
          :event_name => "#{course_name} Enrolled",
          :created_at => Time.now.to_i,
          :user_id => @user.id,
          :email => @user.email,
          :meta_data => {
              'ExamSitting Date' => exam_date
          }
      )
    end

  end

end
