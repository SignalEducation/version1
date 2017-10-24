redis_host = ""
redis_host_port = ""

case Rails.env
when "production"
  redis_host = ENV["REDIS_PRODUCTION_HOST"]
  redis_host_port = ENV["REDIS_PRODUCTION_HOST_PORT"]
when "test"
  redis_host = ENV["REDIS_TEST_HOST"]
  redis_host_port = ENV["REDIS_TEST_HOST_PORT"]
when "development"
  redis_host = ENV["REDIS_DEVELOPMENT_HOST"]
  redis_host_port = ENV["REDIS_DEVELOPMENT_HOST_PORT"]
end

Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://#{redis_host}:#{redis_host_port}/5" }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://#{redis_host}:#{redis_host_port}/5"}
end
