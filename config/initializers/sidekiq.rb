redis_config = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  timeout: 30,
  read_timeout: 30,
  write_timeout: 30
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end