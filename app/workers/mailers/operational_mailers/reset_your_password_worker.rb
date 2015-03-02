class Mailers::OperationalMailers::ResetYourPasswordWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id)
    @user = User.find_by_id(user_id)
    if @user
      OperationalMailer.reset_your_password(@user).deliver
    else
      Rails.logger.error "Mailers::OperationalMailers::ResetYourPasswordWorker could not find user #{user_id}."
    end
  end
end
