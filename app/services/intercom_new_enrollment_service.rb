class IntercomNewEnrollmentService

  def initialize(params)
    @user = User.where(id: params[:user_id]).first
    @course_name = params[:course_name]
    @exam_date = params[:exam_date]
  end

  def perform
    create_intercom_enrollment_event
  end

  private

  def create_intercom_enrollment_event
    if @user
      intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])

      intercom.events.create(
          :event_name => "#{@course_name} Enrolled",
          :created_at => Time.now.to_i,
          :user_id => @user.id,
          :email => @user.email,
          :meta_data => {
              'ExamSitting Date' => @exam_date
          }
      )
    end

  end

end