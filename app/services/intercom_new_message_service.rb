class IntercomNewMessageService

  def initialize(params)
    @user = User.where(id: params[:user_id]).first
    @email = params[:email]
    @type = params[:type]
    @full_name = params[:full_name]
    @message = params[:message]

  end

  def perform
    create_intercom_message
  end

  private

  def create_intercom_message
    intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])

    if @user
      intercom.messages.create(
          :from => {
              :type => "user",
              :email => @email,
              :user_id => @user.id,
          },
          :body => "Type: #{@type}. Name: #{@full_name}. Message: #{@message}"
      )

    else
      contact = intercom.contacts.create(email: @email)
      intercom.messages.create(
          :from => {
              :type => "contact",
              :id => contact.id

          },
          :body => "Type: #{@type}. Name: #{@full_name}. Email: #{@email}. Message: #{@message}."
      )

    end

  end

end