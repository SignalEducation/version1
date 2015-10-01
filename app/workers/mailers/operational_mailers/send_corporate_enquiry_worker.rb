class Mailers::OperationalMailers::SendCorporateEnquiryWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(corporate_request_id)
    @request = CorporateRequest.find_by_id(corporate_request_id)
    OperationalMailer.send_corporate_enquiry_email(@request).deliver_now
  end
end
