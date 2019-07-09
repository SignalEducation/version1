class MailchimpAddEnrollmentTagWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(enrollment_id, state)
    MailchimpService.new.audience_enrollment_tag(enrollment_id, state)

  end

end
