class IntercomCreateCorporateManagerWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id, email, name, created_at, guid, user_group, corp_id, corp_name)
    intercom = Intercom::Client.new(
        app_id: ENV['intercom_app_id'],
        api_key: ENV['intercom_api_key']
    )

    intercom.users.create(user_id: user_id,
                          email: email,
                          name: name,
                          created_at: created_at,
                          custom_data: {guid: guid,
                                        user_group: user_group,
                                        company: {id: corp_id ,name: corp_name}
                          })
  end

end
