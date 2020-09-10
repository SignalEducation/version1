# frozen_string_literal: true

Split.configure do |config|
  config.db_failover = true # handle Redis errors gracefully
  config.db_failover_on_db_error = ->(error) { Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
  config.enabled = true
  config.reset_manually = true
  config.redis = "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/5"
end
