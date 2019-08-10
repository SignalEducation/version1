require 'mandrill'

class MandrillClient
  def initialize(user)
    @user = user
  end

  # Basic Account Emails
  def send_verification_email(verification_url)
    msg = message_stub.merge({"subject" => "Please Verify your email"})
    msg["global_merge_vars"] << { "name" => "VERIFICATIONURL", "content" => verification_url }
    send_template('email-verification-190429', msg)
  end

  def admin_invite(verification_url)
    msg = message_stub.merge({"subject" => "Welcome to LearnSignal"})
    msg["global_merge_vars"] << { "name" => "VERIFICATIONURL", "content" => verification_url }
    send_template('admin-invite-190605', msg)
  end

  def csv_webinar_invite(verification_url)
    msg = message_stub.merge({"subject" => "Your ACCA Webinar with LearnSignal. Let’s get started..."})
    msg["global_merge_vars"] << { "name" => "VERIFICATIONURL", "content" => verification_url }
    send_template('webinar_invite_170824', msg)
  end

  def password_reset_email(password_reset_url)
    msg = message_stub.merge({"subject" => "LearnSignal Password Reset"})
    msg["global_merge_vars"] << { "name" => "PASSWORDRESETURL", "content" => password_reset_url }
    send_template('password-reset-190605', msg)
  end

  def send_set_password_email(set_password_url)
    msg = message_stub.merge({"subject" => "LearnSignal Set Password"})
    msg["global_merge_vars"] << { "name" => "SETPASSWORDURL", "content" => set_password_url }
    send_template('set-password-09-01-18', msg)
  end

  # Subscription/Stripe/Purchase Emails
  def send_card_payment_failed_email(account_settings_url)
    msg = message_stub.merge({"subject" => "LearnSignal - Payment Failed"})
    msg["global_merge_vars"] << { "name" => "ACCOUNTSETTINGSURL", "content" => account_settings_url }
    send_template('card-payment-failed-190605', msg)
  end

  def send_account_suspended_email
    msg = message_stub.merge({"subject" => "LearnSignal - Account Suspended"})
    send_template('account-suspended-190605', msg)
  end

  def send_successful_payment_email(account_url, invoice_url)
    msg = message_stub.merge({"subject" => "LearnSignal - Payment Invoice"})
    msg["global_merge_vars"] << { "name" => "ACCOUNTURL", "content" => account_url }
    msg["global_merge_vars"] << { "name" => "INVOICEURL", "content" => invoice_url }
    send_template('payment-invoice-new-branding-190605', msg)
  end

  def send_referral_discount_email(amount)
    msg = message_stub.merge({"subject" => 'Referral Discount Achieved'})
    msg["global_merge_vars"] << { "name" => "AMOUNT", "content" => amount }
    send_template('referral-discount-20-02-17', msg)
  end

  def send_mock_exam_email(account_url, product_name, guid)
    msg = message_stub.merge({"subject" => "LearnSignal Mock Exam"})
    msg["global_merge_vars"] << { "name" => "NAME", "content" => product_name }
    msg["global_merge_vars"] << { "name" => "ACCOUNTURL", "content" => account_url }
    msg["global_merge_vars"] << { "name" => "GUID", "content" => guid }
    send_template('mock-exam-confirmation-190510', msg)
  end

  def send_correction_returned_email(account_url, product_name)
    msg = message_stub.merge({"subject" => "LearnSignal Corrections Returned"})
    msg["global_merge_vars"] << { "name" => "NAME", "content" => product_name }
    msg["global_merge_vars"] << { "name" => "ACCOUNTURL", "content" => account_url }
    send_template('corrections-returned-190510', msg)
  end

  # Enrollments Emails (Unsubscribe possible)
  def send_enrollment_welcome_email(course_name, url)
    msg = message_stub.merge({"subject" => "Welcome to #{course_name}"})
    msg["global_merge_vars"] << { "name" => "NAME", "content" => course_name }
    msg["global_merge_vars"] << { "name" => "LINK", "content" => url }
    send_template('enrolment_welcome_170811', msg)
  end

  #Free Trial Emails

  def send_free_trial_over_email(new_subscription_url)
    msg = message_stub.merge({"subject" => "Free Trial Expired"})
    msg["global_merge_vars"] << { "name" => "NEWSUBSCRIPTIONURL", "content" => new_subscription_url }
    send_template('free_trial_expired_170811', msg)
  end


  #Other Emails
  def send_survey_email(url)
    msg = message_stub.merge({"subject" => "Student Feedback Survey"})
    msg["global_merge_vars"] << { "name" => "URL", "content" => url }
    send_template('course-completion-survey-190605', msg)
  end

  # Send SCA confirmation email
  def send_sca_confirmation_email(url)
    msg = message_stub.merge({"subject" => "Verify Invoice"})
    msg["global_merge_vars"] << { "name" => "URL", "content" => url }
    send_template('invoice-actionable', msg)
  end

  private

  def send_template(template_slug, msg)
    @mandrill ||= Mandrill::API.new ENV['LEARNSIGNAL_MANDRILL_API_KEY']
    @mandrill.messages.send_template template_slug, nil, msg, false, nil, nil
  end

  def message_stub
    {
      "html" => nil,
      "text" => nil,
      "subject" => nil,
      "from_email" => "team@learnsignal.com",
      "from_name" => "LearnSignal",
      "to" => [{
                 "email" => @user.email,
                 "type" => "to",
                 "name" => @user.full_name || @user.first_name
               }],
      "headers" => nil, #{"Reply-To" => "message.reply.learnsignal@example.com"},
      "important" => false,
      "track_opens" => nil,
      "track_clicks" => nil,
      "auto_text" => nil,
      "auto_html" => nil,
      "inline_css" => nil,
      "url_strip_qs" => nil,
      "preserve_recipients" => nil,
      "view_content_link" => nil,
      "bcc_address" => nil, #"message.bcc_address@example.com",
      "tracking_domain" => nil,
      "signing_domain" => nil,
      "return_path_domain" => nil,
      "merge" => true,
      "merge_language" => "mailchimp",
      "global_merge_vars" => [
        { "name" => "FNAME", "content" => @user.first_name },
        { "name" => "LNAME", "content" => @user.last_name },
        { "name" => "COMPANY", "content" => "Signal Education" },
        { "name" => "COMPANYURL", "content" => "https://learnsignal.com" }
      ],
      "merge_vars" => [
        # { "rcpt" => "some.email@example.com",
        #   "vars" => [{
        #                "FNAME" => "First Name",
        #                "COMPANY" => "Signal Education",
        #                "COMPANYURL" => "http://learnsignal.com"
        #              }],
        # }
      ],
      "tags" => [],
      "subaccount" => nil,
      "google_analytics_domains" => [],
      "google_analytics_campaign" => nil,
      "metadata" => {},
      "recipient_metadata" => [
        # { "rcpt" => "recipient.email@example.com", "values" => { "user_id" => 123456 } }
      ],
      "attachments" => [
        # { "type" => "text/plain", "content" => "ZXhhbXBsZSBmaWxl", "name" => "myfile.txt" }
      ],
      "images" => [
        # { "type" => "image/png", "content" => "ZXhhbXBsZSBmaWxl", "name" => "IMAGECID" }
      ],
    }
  end


end
