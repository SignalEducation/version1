Recaptcha.configure do |config|
  credentials       = Rails.application.credentials[Rails.env.to_sym]
  config.site_key   = credentials[:google][:recaptcha][:site_key]
  config.secret_key = credentials[:google][:recaptcha][:secret_key]
end
