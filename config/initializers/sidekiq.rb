Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/5" }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/5"}
end
