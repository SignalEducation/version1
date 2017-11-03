require 'cron_tasks'

namespace :enrollments do

  desc "Checks for enrollment that haven't been updated in last week and sends an intercom worker"
  task :send_course_progress_to_intercom => :environment do |t|
    CronTasks.create_course_progress_intercom_worker
  end

end
