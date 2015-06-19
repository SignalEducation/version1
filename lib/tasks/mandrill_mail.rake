require 'conditional_mandrill_mails_processor'

namespace :mandrill_mail do
  desc "Sends 'Study Streak' email to users (start calculation from yesterday or today)"
  task :study_streak, [:start_calculation_from] => :environment do |t, args|
    args.with_defaults(start_calculation_from: 'yesterday')
    ConditionalMandrillMailsProcessor.process_study_streak(args.start_calculation_from)
  end
end
