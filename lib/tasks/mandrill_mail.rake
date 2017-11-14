require 'conditional_mandrill_mails_processor'

namespace :mandrill_mail do

  desc "Sends 'We havent seen you in a while' email to users who haven't logged in for 7 days"
  task :we_havent_seen_you_in_a_while => :environment do |t|
    ConditionalMandrillMailsProcessor.process_we_havent_seen_you_in_a_while
  end

end
