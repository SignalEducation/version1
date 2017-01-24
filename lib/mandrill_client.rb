require 'mandrill'

class MandrillClient
  def initialize(user, corporate)
    @user = user
    @corporate = corporate
  end

  # Basic Account Emails
  def send_verification_email(verification_url)
    msg = message_stub.merge({"subject" => "LearnSignal Account Verification"})
    msg["global_merge_vars"] << { "name" => "VERIFICATIONURL", "content" => verification_url }
    send_template('email-verification', msg)
  end

  def admin_invite(verification_url)
    msg = message_stub.merge({"subject" => "Welcome to LearnSignal"})
    msg["global_merge_vars"] << { "name" => "VERIFICATIONURL", "content" => verification_url }
    send_template('admin-invite-email', msg)
  end

  def password_reset_email(password_reset_url)
    msg = message_stub.merge({"subject" => "Learn Signal Password Reset"})
    msg["global_merge_vars"] << { "name" => "PASSWORDRESETURL", "content" => password_reset_url }
    send_template('password-reset-email', msg)
  end


  # Corporate Account Emails
  def corporate_invite(verification_url)
    msg = corporate_message_stub.merge({"subject" => "Welcome to #{@corporate.organisation_name} Training"})
    msg["global_merge_vars"] << { "name" => "VERIFICATIONURL", "content" => verification_url }
    send_template('corporate-invite-email', msg)
  end

  def corporate_password_reset_email(password_reset_url)
    msg = corporate_message_stub.merge({"subject" => "#{@corporate.organisation_name} Password Reset"})
    msg["global_merge_vars"] << { "name" => "PASSWORDRESETURL", "content" => password_reset_url }
    send_template('corporate-password-reset-email', msg)
  end


  # Subscription/Stripe/Purchase Emails
  def send_card_payment_failed_email(account_settings_url)
    msg = message_stub.merge({"subject" => "Payment Failed"})
    msg["global_merge_vars"] << { "name" => "ACCOUNTSETTINGSURL", "content" => account_settings_url }
    send_template('card-payment-failed', msg)
  end

  def send_account_suspended_email
    msg = message_stub.merge({"subject" => "Account Suspended"})
    send_template('account-suspended', msg)
  end

  def send_successful_payment_email(account_url, invoice_url)
    msg = message_stub.merge({"subject" => "LearnSignal Payment Invoice "})
    msg["global_merge_vars"] << { "name" => "ACCOUNTURL", "content" => account_url }
    msg["global_merge_vars"] << { "name" => "INVOICEURL", "content" => invoice_url }
    send_template('invoice-payment-successful', msg)
  end

  def send_subscription_error_email(trial_length)
    msg = message_stub.merge({"subject" => "There's been an error with your subscription"})
    msg["global_merge_vars"] << { "name" => "USERTRIALLENGTH", "content" => trial_length }
    send_template('subscription-error', msg)
  end

  def send_referral_discount_email(amount)
    msg = message_stub.merge({"subject" => 'Referral Discount Achieved'})
    msg["global_merge_vars"] << { "name" => "AMOUNT", "content" => amount }
    send_template('referral-discount-email', msg)
  end

  def send_mock_exam_email(account_url, file_name, attachment)
    msg = message_stub.merge({"subject" => "LearnSignal Mock Exam "})
    msg["global_merge_vars"] << { "name" => "NAME", "content" => file_name }
    msg["global_merge_vars"] << { "name" => "ACCOUNTURL", "content" => account_url }
    msg["global_merge_vars"] << { "name" => "ATTACHMENTURL", "content" => attachment }
    send_template('mock-exam-purchase', msg)
  end

  def send_white_paper_request_email(name, title, url)
    msg = message_stub.merge({"subject" => "#{title}"})
    msg["global_merge_vars"] << { "name" => "NAME", "content" => name }
    msg["global_merge_vars"] << { "name" => "TITLE", "content" => title }
    msg["global_merge_vars"] << { "name" => "URL", "content" => url }
    send_template('white-paper-email', msg)
  end


  # Enrollments Emails (Unsubscribe possible)
  def send_enrollment_welcome_email(course_name, text, url, contact_link)
    msg = message_stub.merge({"subject" => "Welcome to #{course_name}"})
    msg["global_merge_vars"] << { "name" => "NAME", "content" => course_name }
    msg["global_merge_vars"] << { "name" => "TEXT", "content" => text }
    msg["global_merge_vars"] << { "name" => "LINK", "content" => url }
    msg["global_merge_vars"] << { "name" => "CONTACTLINK", "content" => contact_link }
    send_template('enrollment-welcome-email-2017', msg)
  end

  def send_we_havent_seen_you_in_a_while_email(url, course_name, days)
    msg = message_stub.merge({"subject" => "#{course_name} Study"})
    msg["global_merge_vars"] << { "name" => "COURSE_URL", "content" => url }
    msg["global_merge_vars"] << { "name" => "COURSE_NAME", "content" => course_name }
    msg["global_merge_vars"] << { "name" => "DAYS_SINCE_LAST_SEEN", "content" => days }
    send_template('we-havent-seen-you-in-a-while', msg)
  end

  def send_study_streak_email(url, course_name)
    msg = message_stub.merge({"subject" => "#{course_name} Study"})
    msg["global_merge_vars"] << { "name" => "COURSE_URL", "content" => url }
    msg["global_merge_vars"] << { "name" => "COURSE_NAME", "content" => course_name }
    send_template('study-streak', msg)
  end



  #Free Trial Emails
  def send_free_trial_ending_email(new_subscription_url, days_left)
    msg = message_stub.merge({"subject" => "You're free trial with learn signal has just ended"})
    msg["global_merge_vars"] << { "name" => "DAYSLEFT", "content" => days_left }
    msg["global_merge_vars"] << { "name" => "NEWSUBSCRIPTIONURL", "content" => new_subscription_url }
    send_template('free-trial-ending', msg)
  end


  #Other Emails
  def send_tutor_application_email(first_name, last_name, email, info, description)
    msg = message_stub.merge({"subject" => "New Tutor Application"})
    msg["global_merge_vars"] << { "name" => "FIRSTNAME", "content" => first_name }
    msg["global_merge_vars"] << { "name" => "LASTNAME", "content" => last_name }
    msg["global_merge_vars"] << { "name" => "EMAIL", "content" => email }
    msg["global_merge_vars"] << { "name" => "INFO", "content" => info }
    msg["global_merge_vars"] << { "name" => "DESCRIPTION", "content" => description }
    send_template('new-tutor-application', msg)
  end

  def send_corporate_request_email(name, company, email, phone_number)
    msg = message_stub.merge({"subject" => "New Business Account Enquiry"})
    msg["global_merge_vars"] << { "name" => "NAME", "content" => name }
    msg["global_merge_vars"] << { "name" => "COMPANY", "content" => company }
    msg["global_merge_vars"] << { "name" => "EMAIL", "content" => email }
    msg["global_merge_vars"] << { "name" => "PHONENUMBER", "content" => phone_number }
    send_template('new-business-account-enquiry', msg)
  end



  #Turned Off because the mailchimp email template is stupid
  def send_account_reactivated_email(account_settings_url)
    msg = message_stub.merge({"subject" => "Your Account is Reactivated"})
    msg["global_merge_vars"] << { "name" => "ACCOUNTSETTINGSURL", "content" => account_settings_url }
    send_template('account-reactivated', msg)
  end


  private

  def send_template(template_slug, msg)
    @mandrill ||= Mandrill::API.new ENV['learnsignal_mandrill_api_key']
    @mandrill.messages.send_template template_slug, nil, msg, false, nil, nil
  end

  def message_stub
    {
      "html" => nil,
      "text" => nil,
      "subject" => nil,
      "from_email" => "team@learnsignal.com",
      "from_name" => "Learn Signal",
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

  def corporate_message_stub
    {
      "html" => nil,
      "text" => nil,
      "subject" => nil,
      "from_email" => @corporate.corporate_email,
      "from_name" => @corporate.organisation_name,
      "to" => [{
                 "email" => @user.email,
                 "type" => "to",
                 "name" => @user.full_name
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
        { "name" => "COMPANY", "content" => @corporate.organisation_name },
        { "name" => "IMAGENAME", "content" => @corporate.logo.url },
        { "name" => "COMPANYURL", "content" => @corporate.external_url }
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
      "subaccount" => @corporate.subdomain,
      "google_analytics_domains" => [],
      "google_analytics_campaign" => nil,
      "metadata" => {},
      "recipient_metadata" => [
        # { "rcpt" => "recipient.email@example.com", "values" => { "user_id" => 123456 } }
      ],
      "attachments" => [
        # { "type" => "text/plain", "content" => "ZXhhbXBsZSBmaWxl", "name" => "myfile.txt" }
      ]
    }
  end


end
