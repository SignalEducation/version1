class Mailers::OperationalMailers::YourPasswordHasChangedWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    @user = User.find_by_id(user_id)
    if @user
      OperationalMailer.your_password_has_changed(@user).deliver
    else
      Rails.logger.error "Mailers::OperationalMailers::YourPasswordHasChangedWorker could not find user #{user_id}."
    end
  end
end
