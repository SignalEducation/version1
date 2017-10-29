class IntercomCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    user = User.where(id: user_id).first
    if user
      intercom = Intercom::Client.new(
          app_id: ENV['INTERCOM_APP_ID'],
          api_key: ENV['INTERCOM_API_KEY']
      )

      intercom.users.create(user_id: user_id,
                            email: user.email,
                            name: user.full_name,
                            created_at: user.created_at,
                            custom_data: {guid: user.guid,
                                          user_group: user.user_group,
                                          account_status: user.user_account_status,
                                          free_trial: user.free_member?,
                                          valid_free_trial: user.valid_free_member?,
                                          free_trial_days_left: user.days_left,
                                          free_trial_minutes_left: user.minutes_left,
                                          email_verified: user.email_verified,
                                          ga_id: user.analytics_guid,
                                          student_number: user.student_number,
                                          date_of_birth: user.date_of_birth,
                            })
    end
  end

end
