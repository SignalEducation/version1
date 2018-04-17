class IntercomCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    IntercomNewUserService.new({user_id: user_id}).perform
  end

end
