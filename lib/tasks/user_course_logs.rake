require 'cron_tasks'

namespace :user_course_logs do

  desc "Checks whether SET's need to be updated for each course"
  task :check_subscription_cards => :environment do |t|
    CronTasks.check_for_expiring_cards
  end

end
