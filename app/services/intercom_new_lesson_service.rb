class IntercomNewLessonService

  def initialize(params)
    @intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])
    @user = User.where(id: params[:user_id]).first
    @course_name = params[:course_name]
    @module_name = params[:module_name]
    @type = params[:type]
    @lesson_name = params[:lesson_name]
    @video_id = params[:video_id]
    @quiz_score = params[:quiz_score]
  end

  def perform
    create_intercom_lesson_event
  end

  private

  def create_intercom_lesson_event
    if @user

      begin
        intercom_user = @intercom.users.find(user_id: @user.id)
      rescue Intercom::ResourceNotFound
        intercom_user = nil
      end

      if intercom_user
        @intercom.events.create(
            :event_name => "Lesson Event",
            :created_at => Time.now.to_i,
            :user_id => @user.id,
            :email => @user.email,
            :metadata => {
                "lesson_name" => @lesson_name,
                "lesson_type" => @type,
                "module_name" => @module_name,
                "course_name" => @course_name,
                "vimeo_guid" => @video_id,
                "quiz_score" => @quiz_score
            }
        )
      end

    end

  end

end