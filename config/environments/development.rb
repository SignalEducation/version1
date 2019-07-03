Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # email setup
  config.action_mailer.delivery_method = :smtp
  # email delivery through Mandrill
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV['LEARNSIGNAL_V2_SERVER_EMAIL_SMTP'],
    port:                 587,
    domain:               ENV['LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN'],
    user_name:            ENV['LEARNSIGNAL_V3_SERVER_EMAIL_ADDRESS'],
    password:             ENV['LEARNSIGNAL_V3_SERVER_EMAIL_PASSWORD'],
    authentication:       :plain,
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = { host: ENV['LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN'] }

  # see the HerokuDevCenter Article
  # https://devcenter.heroku.com/articles/paperclip-s3
  config.paperclip_defaults = {
    storage: :s3,
    url: ':s3_domain_url',
    path: '/:class/:id/:filename',
    s3_protocol: 'https',
    s3_host_name: 's3-eu-west-1.amazonaws.com',
    s3_credentials: {
      bucket: ENV['LEARNSIGNAL3_BUCKET_NAME'],
      access_key_id: ENV['LEARNSIGNAL3_S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['LEARNSIGNAL3_S3_SECRET_ACCESS_KEY'],
      s3_region: 'eu-west-1'
    }
  }
  #Enable bullet in your application
  Bullet.enable = true
  Bullet.rails_logger = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end

# Required by LogEntries
#Rails.logger = Le.new('d494abe7-91a6-4062-aacf-39a9544a69bc', # dev
#                      debug: true, # logs debug-level events to LE
#                      ssl: true, # encrypt our log transmissions
#                      local: true # keep local logs as well
#)

Rails.application.routes.default_url_options = { host: 'localhost:3000' }
