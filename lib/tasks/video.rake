namespace :video do
  # This rake task is called from the cron.

  desc 'Find new videos in the S3 inbox and schedule them for transcoding'
  task(find_new: :environment) do
    # USAGE: rake video:find_new
    RawVideoFileWorker.perform_async
  end

  desc 'Check for updates on transcode jobs in progress'
  task(check_transcodes_in_progress: :environment) do
    # USAGE: rake video:check_transcodes_in_progress
    TranscodeMessagesWorker.perform_async
  end

end
