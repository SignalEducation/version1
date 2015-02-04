namespace :video do
  # This rake task is called from the cron.

  desc 'Find new videos in the S3 inbox and schedule them for transcoding'
  task(find_new: :environment) do
    # USAGE: rake video:find_new
    message_1 = "RAKE video:find_new starting ENV:#{Rails.env} at #{Time.now}."
    Rails.logger.info message_1
    puts message_1
    RawVideoFileWorker.perform_async
    message_2 = "RAKE video:find_new finished ENV:#{Rails.env} at #{Time.now}."
    Rails.logger.info message_2
    puts message_2
  end

  desc 'Check for updates on transcode jobs in progress'
  task(check_transcodes_in_progress: :environment) do
    # USAGE: rake video:check_transcodes_in_progress
    message_1 = "RAKE video:check_transcodes_in_progress starting ENV:#{Rails.env} at #{Time.now}."
    Rails.logger.info message_1
    puts message_1
    TranscodeMessagesWorker.perform_async
    message_2 = "RAKE video:check_transcodes_in_progress finished ENV:#{Rails.env} at #{Time.now}."
    Rails.logger.info message_2
    puts message_2
  end

end
