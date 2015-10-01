class Mailers::OperationalMailers::SendCorporateEnquiryWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(corporate_request)
    OperationalMailer.send_corporate_enquiry_email(corporate_request).deliver_now
  end
end
