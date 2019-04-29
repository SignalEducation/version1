class IntercomCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    intercom = InitializeIntercomClientService.new().perform

    user = User.where(id: user_id).first

    if user

      intercom.users.create(user_id: user.id,
                            email: user.email,
                            name: user.full_name,
                            created_at: user.created_at,
                            custom_attributes: {guid: user.guid,
                                          user_group: user.user_group,
                                          email_verified: user.email_verified,
                                          date_of_birth: user.date_of_birth,
                                          preferred_exam_body: user.preferred_exam_body.try(:name),
                            })

    end
  end

end
