class OperationalMailer < ActionMailer::Base

  default from: ENV['learnsignal_v3_server_email_address']
  layout 'email_template'

  before_action :set_the_url

  def activate_account(user)
    @user = user
    mail(to: @user.email,
        subject: I18n.t('mailers.operational.activate_account.subject_line')
    )
  end

  def your_password_has_changed(user)
    @user = user
    mail(to: @user.email,
        subject: I18n.t('mailers.operational.your_password_has_changed.subject_line')
    )
  end

  def reset_your_password(user)
    @user = user
    mail(to: @user.email,
         subject: I18n.t('mailers.operational.reset_your_password.subject_line')
    )
  end
  protected

  def set_the_url
    if Rails.env.development? || Rails.env.test?
      @url = 'http://localhost:3000/'
    elsif Rails.env.staging?
      @url = 'http://staging3.learnsignal.com/'
    else
      @url = 'https://production3.learnsignal.com/'
    end
  end

end
