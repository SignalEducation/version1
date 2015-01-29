class UserLoggerWorker
  include Sidekiq::Worker

  sidekiq_options retry: 10, queue: 'low'

  sidekiq_retries_exhausted do |msg|
    Rails.logger.warn "WARNING: Sidekiq retries exhausted. Message:#{msg['class']} with #{msg['args']}: #{msg['error_message']}."
  end

  def perform(job_guid, user_id, session_guid, req_filtered_path, the_controller_name,
              the_action_name, req_parameters, remote_ip, the_user_agent)
    the_user = User.find_by_id(user_id)
    log = UserActivityLog.new(
            user_id: the_user.try(:id),
            session_guid: session_guid,
            signed_in: !the_user.try(:id).nil?,
            original_uri: req_filtered_path,
            controller_name: the_controller_name,
            action_name: the_action_name,
            params: req_parameters,
            ip_address: remote_ip,
            alert_level: 0,
            http_user_agent: the_user_agent,
            guid: job_guid
    )
    if log.save
      true
    elsif log.errors[:guid].include?('has already been taken')
      Rails.logger.warn "WARNING: UserLoggerWorker#perform tried to save a UserActivityLog multiple times. @log:#{log.errors.inspect}."
      return false
    else
      Rails.logger.error "ERROR: UserLoggerWorker#perform failed to save a UserActivityLog. @log:#{log.errors.inspect}."
      false # puts the job back in the queue
    end
  end

end
