require 'mandrill'

class MandrillClient
  def initialize(user, request)
    @user = user
    @request = request
  end

  def send_verification_email(verification_url)
    msg = message_stub.merge({"subject" => "Subscription Verification"})
    msg["global_merge_vars"] << { "name" => "VERIFICATIONURL", "content" => verification_url }
    send_template('email-verification', msg)
  end

  def send_welcome_email(trial_length, library_url)
    msg = message_stub.merge({"subject" => "Welcome to Learn Signal"})
    msg["global_merge_vars"] << { "name" => "USERTRIALLENGTH", "content" => trial_length }
    msg["global_merge_vars"] << { "name" => "USERLIBRARYURL", "content" => library_url }
    send_template('welcome-email', msg)
  end

  def send_subscription_error_email(trial_length)
    msg = message_stub.merge({"subject" => "There's been an error with your subscription"})
    msg["global_merge_vars"] << { "name" => "USERTRIALLENGTH", "content" => trial_length }
    send_template('subscription-error', msg)
  end

  def send_free_trial_ended_email(account_activation_url)
    msg = message_stub.merge({"subject" => ":( You're free trial with learn signal has just ended"})
    msg["global_merge_vars"] << { "name" => "ACCOUNTACTIVATIONURL", "content" => account_activation_url }
    send_template('free-trial-ended', msg)
  end

  def send_account_suspended_email
    msg = message_stub.merge({"subject" => "Account Suspended"})
    send_template('account-suspended', msg)
  end

  def send_card_payment_failed_email(account_settings_url)
    msg = message_stub.merge({"subject" => "Payment Failed"})
    msg["global_merge_vars"] << { "name" => "ACCOUNTSETTINGSURL", "content" => account_settings_url }
    send_template('card-payment-failed', msg)
  end

  def send_account_reactivated_email(account_settings_url)
    msg = message_stub.merge({"subject" => "Your Account is Reactivated"})
    msg["global_merge_vars"] << { "name" => "ACCOUNTSETTINGSURL", "content" => account_settings_url }
    send_template('account-reactivated', msg)
  end

  def send_password_reset_email(password_reset_url)
    msg = message_stub.merge({"subject" => "Learn Signal Password Reset"})
    msg["global_merge_vars"] << { "name" => "PASSWORDRESETURL", "content" => password_reset_url }
    send_template('password-reset', msg)
  end

  def send_study_streak_email(continue_url)
    msg = message_stub.merge({"subject" => "9 Day Study Streak"})
    msg["global_merge_vars"] << { "name" => "CONTINUEURL", "content" => continue_url }
    send_template('study-streak', msg)
  end

  def send_we_havent_seen_you_in_a_while_email(n_days_since_last_seen, subscribed_course,
                                               cme_one, cme_one_n_videos, cme_one_n_quizzes,
                                               cme_two, cme_two_n_videos, cme_two_n_quizzes,
                                               cme_three, cme_three_n_videos, cme_three_n_quizzes)
    msg = message_stub.merge({"subject" => "We havent seen you in a while!"})
    msg["global_merge_vars"] << { "name" => "N_DAYS_SINCE_LAST_SEEN", "content" => n_days_since_last_seen }
    msg["global_merge_vars"] << { "name" => "SUBSCRIBED_COURSE", "content" => subscribed_course }
    msg["global_merge_vars"] << { "name" => "CME_ONE", "content" => cme_one }
    msg["global_merge_vars"] << { "name" => "CME_ONE_N_VIDEOS", "content" => cme_one_n_videos }
    msg["global_merge_vars"] << { "name" => "CME_ONE_N_QUIZZES", "content" => cme_one_n_quizzes }
    msg["global_merge_vars"] << { "name" => "CME_TWO", "content" => cme_two }
    msg["global_merge_vars"] << { "name" => "CME_TWO_N_VIDEOS", "content" => cme_two_n_videos }
    msg["global_merge_vars"] << { "name" => "CME_TWO_N_QUIZZES", "content" => cme_two_n_quizzes }
    msg["global_merge_vars"] << { "name" => "CME_THREE", "content" => cme_three }
    msg["global_merge_vars"] << { "name" => "CME_THREE_N_VIDEOS", "content" => cme_three_n_videos }
    msg["global_merge_vars"] << { "name" => "CME_THREE_N_QUIZZES", "content" => cme_three_n_quizzes }
    send_template('we-havent-seen-you-in-a-while', msg)
  end

  def send_congrats_on_finishing_the_course_learn_again_email(course_name, course_survey_url,
                                                              course_1, course_1_url, course_1_author, course_1_description,
                                                              course_2, course_2_url, course_2_author, course_2_description,
                                                              course_3, course_3_url, course_3_author, course_3_description,
                                                              course_4, course_4_url, course_4_author, course_4_description)
    msg = message_stub.merge({"subject" => "Congratulations on completing the #{course_name} course! Why not keep on learning?"})
    msg["global_merge_vars"] << { "name" => "COURSE_NAME", "content" => course_name }
    msg["global_merge_vars"] << { "name" => "COURSE_SURVEY_URL", "content" => course_survey_url }
    msg["global_merge_vars"] << { "name" => "COURSE_1", "content" => course_1 }
    msg["global_merge_vars"] << { "name" => "COURSE_1_URL", "content" => course_1_url }
    msg["global_merge_vars"] << { "name" => "COURSE_1_AUTHOR", "content" => course_1_author }
    msg["global_merge_vars"] << { "name" => "COURSE_1_DESCRIPTION", "content" => course_1_description }
    msg["global_merge_vars"] << { "name" => "COURSE_2", "content" => course_2 }
    msg["global_merge_vars"] << { "name" => "COURSE_2_URL", "content" => course_2_url }
    msg["global_merge_vars"] << { "name" => "COURSE_2_AUTHOR", "content" => course_2_author }
    msg["global_merge_vars"] << { "name" => "COURSE_2_DESCRIPTION", "content" => course_2_description }
    msg["global_merge_vars"] << { "name" => "COURSE_3", "content" => course_3 }
    msg["global_merge_vars"] << { "name" => "COURSE_3_URL", "content" => course_3_url }
    msg["global_merge_vars"] << { "name" => "COURSE_3_AUTHOR", "content" => course_3_author }
    msg["global_merge_vars"] << { "name" => "COURSE_3_DESCRIPTION", "content" => course_3_description }
    msg["global_merge_vars"] << { "name" => "COURSE_4", "content" => course_4 }
    msg["global_merge_vars"] << { "name" => "COURSE_4_URL", "content" => course_4_url }
    msg["global_merge_vars"] << { "name" => "COURSE_4_AUTHOR", "content" => course_4_author }
    msg["global_merge_vars"] << { "name" => "COURSE_4_DESCRIPTION", "content" => course_4_description }
    send_template('congrats-on-finishing-the-course-learn-again', msg)
  end


  def send_white_paper_email(title, url)
    msg = request_message_stub.merge({"subject" => "Your Requested Media Download - from LearnSignal"})
    msg["global_merge_vars"] << { "name" => "TITLE", "content" => title }
    msg["global_merge_vars"] << { "name" => "URL", "content" => url }
    send_template('white-paper-request', msg)
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
        { "name" => "COMPANY", "content" => "Signal Education" },
        { "name" => "COMPANYURL", "content" => "http://learnsignal.com" }
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

  def request_message_stub
    {
        "html" => nil,
        "text" => nil,
        "subject" => nil,
        "from_email" => "team@learnsignal.com",
        "from_name" => "Learn Signal",
        "to" => [{
                     "email" => @request.email,
                     "type" => "to",
                     "name" => @request.name
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
            { "name" => "FNAME", "content" => @request.name },
            { "name" => "COMPANY", "content" => "Signal Education" },
            { "name" => "COMPANYURL", "content" => "http://learnsignal.com" }
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
