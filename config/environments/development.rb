Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # email setup
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
          address:              'smtp.gmail.com',
          port:                 587,
          #domain:              'learnsignal.com',
          user_name:            ENV['learnsignal_v3_server_email_address'],
          password:             ENV['learnsignal_v3_server_email_password'],
          authentication:       'plain',
          enable_starttls_auto: true
  }

  # see the HerokuDevCenter Article
  # https://devcenter.heroku.com/articles/paperclip-s3
  config.paperclip_defaults = {
      storage: :s3,
      url: ':s3_domain_url',
      path: '/:class/:id/:filename',
      s3_host_name: 's3-eu-west-1.amazonaws.com',
      s3_credentials: {
          bucket: ENV['LEARNSIGNAL3_BUCKET_NAME'],
          access_key_id: ENV['LEARNSIGNAL3_S3_ACCESS_KEY_ID'],
          secret_access_key: ENV['LEARNSIGNAL3_S3_SECRET_ACCESS_KEY']
      }
  }
end

# Required by LogEntries
#Rails.logger = Le.new('d494abe7-91a6-4062-aacf-39a9544a69bc', # dev
#                      debug: true, # logs debug-level events to LE
#                      ssl: true, # encrypt our log transmissions
#                      local: true # keep local logs as well
#)

Rails.application.routes.default_url_options = { host: 'localhost:3000' }
