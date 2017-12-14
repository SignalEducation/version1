require 'cron_tasks'

namespace :system_cron_rake_tasks do

  desc "Checks whether SCUL's need to be updated for each course"
  task :update_course_user_logs => :environment do |t|
    CronTasks.update_subject_course_user_logs
  end

end
