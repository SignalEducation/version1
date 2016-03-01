class IntercomUserInviteEmailWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(email, url)
    intercom = Intercom::Client.new(
        app_id: ENV['intercom_app_id'],
        api_key: ENV['intercom_api_key']
    )

    content = "<table border='0' width='100%' height='100%' cellpadding='0' cellspacing='0' bgcolor='#f0f0f0'> <tr> <td align='center' valign='top' bgcolor='#f0f0f0' style='background-color: #f0f0f0;'> <table width='600' cellpadding='0' cellspacing='0' border='0' class='container' bgcolor='#ffffff'> <tr> <td class='logo'> <img src='https://s3-eu-west-1.amazonaws.com/learnsignal3-production/public/logo_email_header_3.png' title='LearnSignal Logo' style='max-width: 60%; margin: 0;'> </td> </tr> <tr> <td class='container-padding' bgcolor='#ffffff' style='background-color: #ffffff; padding-left: 30px; padding-right: 30px;'> <h2>Hi James,</h2> <p>Welcome to LearnSignal. Please click on the link below to get started: </p> <p>#{url}</p> </td> </tr> <tr> <td> <hr/> <table border='0' width='100%' height='100%' cellpadding='0' cellspacing='0' bgcolor='#fbfbfb' class='footer'> <tr> <td class='social'> Follow us: <a href='https://twitter.com/learnsignal' class='twitter'><img src='https://cl.ly/image/3F1s2K34012V/twitter.png' width='20' height='20'> Twitter</a> <a href='https://www.facebook.com/learnsignal1' class='facebook'><img src='https://cl.ly/image/3P3M3S1T093M/facebook.png' width='20' height='20'> Facebook</a> </td> </tr> </table> </td> </tr> </table> </td> </tr></table>"

    intercom.messages.create({
                                 :message_type => 'email',
                                 :subject  => 'Welcome to LearnSignal',
                                 :body     => content,
                                 :template => 'personal',
                                 :from => {:type => "admin",
                                           :id   => "35759"},
                                 :to => {:type => "user",
                                         :email => email} })
  end

end
