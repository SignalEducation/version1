class Mailers::OperationalMailers::ActivateAccountWorker
  include Sidekiq::Worker

  def perform(user_id)
    @user = User.find(user_id)
    OperationalMailer.activate_account(@user).deliver
  end
end
