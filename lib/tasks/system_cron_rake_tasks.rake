require 'cron_tasks'

namespace :system_cron_rake_tasks do

  desc "Checks whether SCUL's need to be updated for each course"
  task :update_course_user_logs => :environment do |t|
    CronTasks.update_subject_course_user_logs
  end

  desc 'Find & Update users to expired free trial'
  task :free_trial_ended => :environment do |t|
    CronTasks.process_free_trial_ended_users
  end

end
