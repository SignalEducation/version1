class Mailers::OperationalMailers::ActivateAccountWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id)
    @user = User.find_by_id(user_id)
    if @user
      OperationalMailer.activate_account(@user).deliver_now
    else
      Rails.logger.error "Mailers::OperationalMailers::ActivateAccountWorker could not find user #{user_id}."
    end
  end

end
