class IntercomCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    user = User.where(id: user_id).first
    intercom = Intercom::Client.new(
        app_id: ENV['intercom_app_id'],
        api_key: ENV['intercom_api_key']
    )

    intercom.users.create(user_id: user_id,
                          email: user.email,
                          name: user.full_name,
                          created_at: user.created_at,
                          custom_data: {guid: user.guid,
                                        user_group: user.user_group,
                                        free_trial: user.valid_free_member?,
                                        email_verified: user.email_verified,
                                        topic_interest: user.topic_interest,

                          })
  end

end
