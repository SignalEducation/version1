require 'conditional_mandrill_mails_processor'

namespace :user_course_logs do

  desc "Checks whether SET's need to be updated for each course"
  task :update_student_exam_tracks => :environment do |t|
    CronTasks.process_student_exam_tracks
  end

end
