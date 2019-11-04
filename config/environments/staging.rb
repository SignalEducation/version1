Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  config.assets.gzip = true # enable gzipped assets generation

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = false

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

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

  config.exceptions_app = self.routes
  config.action_dispatch.trusted_proxies = ActionDispatch::RemoteIp::TRUSTED_PROXIES +
                                           ENV['AWS_LOAD_BALANCERS'].split(',').map { |alp| IPAddr.new(alp) }
end

# Required by LogEntries
#Rails.logger = Le.new('133cb62a-cefa-43a4-b277-f7f87a78ac54', # staging
#                      debug: true, # logs debug-level events to LE
#                      ssl: true, # encrypt our log transmissions
#                      local: true # keep local logs as well
#)
