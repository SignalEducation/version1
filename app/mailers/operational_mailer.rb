class OperationalMailer < ActionMailer::Base

  default from: ENV['learnsignal_v3_server_email_address']
  layout 'email_template'

  before_action :set_the_url

  def send_corporate_enquiry_email(corporate_request) # backgrounded
    @request = corporate_request
    emails = ['philip@learnsignal.com', 'conn@learnsignal.com', 'johnny@learnsignal.com', 'chris@learnsignal.com' , 'acb9b393@email.getbase.com']
    mail(to: emails,
         subject: I18n.t('mailers.operational.corporate_enquiry.subject_line')
    )
  end

  def signup_completed(user) # backgrounded
    @user = user
    mail(to: @user.email,
         subject: I18n.t('mailers.operational.signup_completed.subject_line')
    )
  end

  def activate_account(user) # backgrounded
    @user = user
    mail(to: @user.email,
        subject: I18n.t('mailers.operational.activate_account.subject_line')
    )
  end

  def reset_your_password(user) # backgrounded
    @user = user
    mail(to: @user.email,
         subject: I18n.t('mailers.operational.reset_your_password.subject_line')
    )
  end

  def send_user_notification(user_notification) # backgrounded
    @user_notification = user_notification
    mail(to: @user_notification.user.email,
         subject: I18n.t('mailers.operational.send_user_notification.subject_line')
    )
  end

  def your_password_has_changed(user) # backgrounded
    @user = user
    mail(to: @user.email,
        subject: I18n.t('mailers.operational.your_password_has_changed.subject_line')
    )
  end

  protected

  def set_the_url
    if Rails.env.development? || Rails.env.test?
      @url = 'http://localhost:3000/'
    elsif Rails.env.staging?
      @url = 'http://staging3.learnsignal.com/'
    else
      @url = 'https://learnsignal.com/'
    end
  end

end
