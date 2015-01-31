namespace :video do
  # This rake task is called from the cron.

  desc 'Find new videos in the S3 inbox and schedule them for transcoding'
  task(find_new: :environment) do
    # USAGE: rake video:find_new
    RawVideoFileWorker.perform_async
  end

end
