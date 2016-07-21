class MandrillWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'high'

  def perform(user_id, method_name, *template_args)
    @user = User.find_by_id(user_id)
    @corporate = CorporateCustomer.find_by_id(@user.corporate_customer_id)
    if @user && @user.email
      mc = MandrillClient.new(@user, @corporate)
      mc.send(method_name, *template_args)
    end
  end
end
