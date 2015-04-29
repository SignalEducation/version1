class Mailers::OperationalMailers::SignupCompletedWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_id)
    @user = User.find_by_id(user_id)
    if @user
      OperationalMailer.signup_completed(@user).deliver
    else
      Rails.logger.error "Mailers::OperationalMailers::SignupCompletedWorker could not find user #{user_id}."
    end
  end

end
