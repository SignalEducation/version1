class IntercomNewSubscriptionLoadService

  def initialize(params)
    @user = User.where(id: params[:user_id]).first
    @country_name = params[:country_name]
  end

  def perform
    create_intercom_upgrade_load_event
  end

  private

  def create_intercom_upgrade_load_event
    if @user
      intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])
      intercom_user = intercom.users.find(user_id: @user.id)

      if intercom_user
        intercom.events.create(
            :event_name => 'Upgrade Page Load',
            :created_at => Time.now.to_i,
            :user_id => @user.id,
            :email => @user.email,
            :metadata => {
                "Ip Country" => @country_name
            }
        )
      end
    end

  end

end