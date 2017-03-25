require 'cron_tasks'

namespace :check_payment_cards do

  desc 'Checks whether any of the default cards are expiring soon and sends email'
  task :update_student_exam_tracks => :environment do |t|
    CronTasks.process_student_exam_tracks
  end

end
