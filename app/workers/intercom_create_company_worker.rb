class IntercomCreateCompanyWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(id, name)
    intercom = Intercom::Client.new(
        app_id: ENV['intercom_app_id'],
        api_key: ENV['intercom_api_key']
    )

    intercom.companies.create(:company_id => id, :name => name)

  end

end
