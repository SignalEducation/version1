require 'cron_tasks'

namespace :enrollments do

  desc "Checks for enrollment that haven't been updated in 6 months and pauses them"
  task :pause_enrollments => :environment do |t|
    CronTasks.pause_inactive_enrollments
  end

end
