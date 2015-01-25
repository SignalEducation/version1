class BlogMailer < ActionMailer::Base

  default from: ENV['learnsignal_v3_server_email_address']
  layout 'email_template'

end
