class TranscodeMessagesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: 'medium'

  def perform
    RawVideoFile.look_for_sqs_updates
  end

end
