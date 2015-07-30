require 'conditional_mandrill_mails_processor'

namespace :mandrill_mail do
  desc "Sends 'Study Streak' email to users (start calculation from yesterday or today)"
  task :study_streak, [:start_calculation_from] => :environment do |t, args|
    args.with_defaults(start_calculation_from: 'yesterday')
    ConditionalMandrillMailsProcessor.process_study_streak(args.start_calculation_from)
  end

  desc "Sends 'We havent seen you in a while' email to users who haven't logged in for 7 days"
  task :we_havent_seen_you_in_a_while => :environment do |t|
    ConditionalMandrillMailsProcessor.process_we_havent_seen_you_in_a_while
  end

  desc "Sends 'Free Trial Ended' email to users"
  task :free_trial_ended => :environment do |t|
    ConditionalMandrillMailsProcessor.process_free_trial_ended_notifications
  end
end
