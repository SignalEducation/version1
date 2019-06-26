class MailchimpService

  def initialize
    if ENV['LEARNSIGNAL_MAILCHIMP_API_KEY']
      @mailchimp = Gibbon::Request.new(api_key: 'd2eee250b68117a0ab90b6c03c0ca9d9-us3', symbolize_keys: true)
      @mailchimp.timeout = 30
      @mailchimp.open_timeout = 30
    end
  end

  def create_audience(exam_body_id)
    body = ExamBody.find(exam_body_id)

    params = {
        "name" => body.name,
        "contact" => {
            "company" => "Your Company",
            "address1" => "address one",
            "address2" => "address two",
            "city" => "city",
            "state" => "state",
            "zip" => "zip-code",
            "country" => "country name",
            "phone" => "phone"
        },
        "permission_reminder" => "You are receiving this email, because you registered for a learnsignal membership.",
        "campaign_defaults" => {
            "from_name" => "James",
            "from_email" => "james@learnsignal.com",
            "subject" => "",
            "language" => "en"
        },
        "email_type_option" => true
    }

    mail_chimp_list = @mailchimp.lists.create(body: params)
    body.update_attribute(:audience_guid, mail_chimp_list.body[:id])
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Country", tag: "COUNTRY", type: "text"})
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Email Verified", tag: "VERIFIED", type: "text"})
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Date of Birth", tag: "DOB", type: "date"})
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Student Number", tag: "SNUM", type: "text"})
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Account Status", tag: "STATUS", type: "text"})
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Login Count", tag: "LCOUNT", type: "number"})
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Last Login", tag: "LASTLOGIN", type: "date"})
    @mailchimp.lists(body.audience_guid).merge_fields.create(body: {name: "Last Lesson", tag: "LASTLESSON", type: "date"})
  end

  def add_subscriber(exam_body_id, user_id, subscribe)
    status = (subscribe ? 'subscribed' : 'unsubscribed')
    exam_body = ExamBody.find(exam_body_id)
    user = User.find(user_id)
    #student_number = user.exam_body_user_details.for_exam_body(exam_body_id).first.student_number if user.exam_body_user_details.for_exam_body(exam_body_id).first
    member = list(exam_body.audience_guid, user).upsert(
        body: {
            email_address: user.email,
            status: status,
            merge_fields: {
                FNAME:  user.first_name.to_s,
                LNAME: user.last_name.to_s,
                COUNTRY: user.country.name.to_s,
                VERIFIED: user.email_verified,
                DOB: user.date_of_birth,
                SNUM: student_number,
                STATUS: student_number,
                LCOUNT: user.login_count,
                LASTLOGIN: user.current_login_at,
                LASTLESSON: user.last_studied_date
            }
        }
    )
    Rails.logger.debug "DEBUG: MailChimp#add_subscriber - Response: #{member.body}"
  rescue Gibbon::MailChimpError => e
    raise e
  end


  def list(list_id, user)
    @mailchimp.lists(list_id).members(
        Digest::MD5.hexdigest(user.email.downcase)
    )
  end

end
