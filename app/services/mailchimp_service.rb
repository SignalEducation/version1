class MailchimpService

  #MailchimpFailed = Class.new(ServiceActionError)

  def initialize
    if ENV['LEARNSIGNAL_MAILCHIMP_API_KEY']
      @mailchimp = Gibbon::Request.new(api_key: ENV['LEARNSIGNAL_MAILCHIMP_API_KEY'], symbolize_keys: true)
      @mailchimp.timeout = 30
      @mailchimp.open_timeout = 30
    end
  end

  def add_subscriber(list_id, user_id, subscribe = true)
    #raise MailchimpFailed.new unless @mailchimp

    user = User.find(user_id)
    #student_number = user.exam_body_user_details
    status = (subscribe ? 'subscribed' : 'unsubscribed')
    list(list_id, user).upsert(
        body: {
            email_address: user.email,
            status: status,
            merge_fields: {
                FNAME:  user.first_name.to_s,
                LNAME: user.last_name.to_s,
                COUNTRY: user.country.name.to_s,
                #DOB: user.date_of_birth,
                #SNUMBER: student_number.to_s,

            }
        }
    )
  rescue Gibbon::MailChimpError => e
    raise e
  end


  def list(list_id, user)
    @mailchimp.lists(list_id).members(
        user.email
    )
  end

end
