class OperationalMailer < ActionMailer::Base

  default from: ENV['development_test_gmail_address']
  layout 'email_template'

  before_action :set_the_url

  def activate_account(user)
    @user = user
    mail(to: @user.email,
        subject: I18n.t('mailers.operational.activate_account.subject_line')
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
