class IntercomNewUserService

  def initialize(params)
    @user = User.where(id: params[:user_id]).first
  end

  def perform
    create_intercom_user
  end

  private

  def create_intercom_user
    if @user
      intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])

      intercom.users.create(user_id: @user.id,
                                    email: @user.email,
                                    name: @user.full_name,
                                    created_at: @user.created_at,
                                    custom_data: {guid: @user.guid,
                                                  user_group: @user.user_group,
                                                  account_status: @user.user_account_status,
                                                  email_verified: @user.email_verified,
                                                  ga_id: @user.analytics_guid,
                                                  student_number: @user.student_number,
                                                  date_of_birth: @user.date_of_birth,
                                    })
    end

  end

end