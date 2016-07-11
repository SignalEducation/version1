require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LearnsignalV3
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths << Rails.root.join('services')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Dublin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')] # see http://guides.rubyonrails.org/i18n.html
    config.i18n.default_locale = :en

    # suggested by Tinfoil Security 29/10/2014
    config.action_dispatch.default_headers = {
            'X-Frame-Options' => 'DENY' # SAMEORIGIN
            #       'Content-Security-Policy' => {'frame-ancestors' => 'none'}
    }

    # see http://guides.rubyonrails.org/generators.html
    config.generators do |g|
      g.orm             :active_record
      g.template_engine :haml
      #g.test_framework  :rspec
      g.stylesheets     false
      g.javascripts     false
      g.helper          false
    end

    # to enable Rack-Attack gem
    #config.middleware.use Rack::Attack
  end
end
