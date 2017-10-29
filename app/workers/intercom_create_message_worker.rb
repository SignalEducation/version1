class IntercomCreateMessageWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, email, full_name, message, type)
    intercom = Intercom::Client.new(
        app_id: ENV['INTERCOM_APP_ID'],
        api_key: ENV['INTERCOM_API_KEY']
    )

    if user_id
      user = User.where(id: user_id).first
      if user
        intercom.messages.create(
            :from => {
                :type => "user",
                :email => email,
                :user_id => user_id,
            },
            :body => "Type: #{type}. Name: #{full_name}. Message: #{message}"
        )
      end
    else
      contact = intercom.contacts.create(email: email)

      intercom.messages.create(
          :from => {
              :type => "contact",
              :id => contact.id

          },
          :body => "Type: #{type}. Name: #{full_name}. Email: #{email}. Message: #{message}."
      )
    end
  end

end
