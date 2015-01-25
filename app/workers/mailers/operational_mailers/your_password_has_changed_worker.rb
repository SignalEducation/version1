class Mailers::OperationalMailers::YourPasswordHasChangedWorker
  include Sidekiq::Worker

  def perform(user_id)
    @user = User.find(user_id)
    OperationalMailer.your_password_has_changed(@user).deliver
  end
end
