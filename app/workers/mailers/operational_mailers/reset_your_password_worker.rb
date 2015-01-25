class Mailers::OperationalMailers::ResetYourPasswordWorker
  include Sidekiq::Worker

  def perform(user_id)
    @user = User.find(user_id)
    OperationalMailer.reset_your_password(@user).deliver
  end
end
