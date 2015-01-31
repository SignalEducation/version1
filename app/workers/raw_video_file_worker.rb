class RawVideoFileWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: 'medium'

  def perform
    RawVideoFile.get_new_videos
  end

end
