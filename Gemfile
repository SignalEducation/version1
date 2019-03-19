source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
 
ruby '2.5.3'
gem 'rails', '5.2.2'

# Use Puma as the app server
gem 'puma', '~> 3.11'

# Core gems - common to all environments
gem 'airbrake', '~> 8.0.1'
gem 'authlogic', '~> 5.0.0'
gem 'ahoy_matey' # visit tracking
gem 'uuidtools', '~> 2.1', '>= 2.1.5'
gem 'blazer'
gem 'scrypt' # S-Crypt for Authlogic
# gem 'autoprefixer-rails', '~> 5.0.0.1' # required by bootstrap-sass
gem 'aws-sdk-s3', '~> 1'
gem 'bootstrap', '~> 4.3.1'
gem 'browser' # user-agent detection
gem 'chart-js-rails', '~> 0.1.6' #Graphs
gem 'coffee-rails', '~> 4.2' # enables CoffeeScript (abbreviated javascript)
gem 'dynamic_sitemaps' # Sitemap generation grm
gem 'faraday', '~> 0.15.4'
gem 'geocoder', '~> 1.3', '>= 1.3.7'#  a public API for geo-locating IP addresses
gem 'haml-rails' # a replacement system for HTML
gem 'intercom-rails' # communicate with Intercom.io
gem 'intercom', '~> 3.5.23' # Intercom API
gem 'jbuilder', '~> 2.5' # https://github.com/rails/jbuilder
gem 'jquery-rails' # include jQuery for Rails
gem 'jquery-ui-rails' # include jQuery UI for Rails
gem 'le' # logEntries.com
gem 'mathjax-rails' # maths functions in the UI
gem 'prawn' # PDF creator
gem 'prawn-table', '~> 0.2.2'
gem 'paperclip', '~> 6.1.0' # for uploading files (works with RemotiPart)
gem 'mailchimp-api', '~> 2.0.4'
gem 'momentjs-rails', '>= 2.9.0'
gem 'modernizr-rails'
gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'
gem 'multipart-post' #To allow uploading wistia api
gem 'pg' # PostgreSQL database engine
gem 'rack-attack'
gem 'redis-rails' #use redis from AWS Elasticache service
# gem 'redis', '~> 4.0'
gem 'remotipart' # enables file upload in forms that work using AJAX
gem 'remodal-rails'
gem 'rails_real_favicon'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'sidekiq', require: %w(sidekiq sidekiq/web)
        # background processor for tasks that can be run 'later' or take too long
        # Requires Redis NoSQL datastore
gem 'sinatra' # needed for sidekiq's web UI
gem 'state_machines-activerecord'
gem 'stripe', '~> 4.5.0' #, git: 'https://github.com/stripe/stripe-ruby'
gem 'paypal-sdk-rest'
gem 'summernote-rails'
gem 'turbolinks', '~> 5' # speeds up page loading - has negative side-effects
gem 'uglifier', '>= 1.3.0' # compresses Javascript when sending it to users in production
gem 'utf8-cleaner' # removes illegal characters from inbound requests
gem 'will_paginate' # manage long web pages
gem 'will_paginate-bootstrap' # adds Bootstrap3 support to will_paginate
gem 'font-awesome-rails' # Font Awesome with lot of useful icons
gem 'zeroclipboard-rails' # For copying referral code URL to clipboard (works only if Flash is enabled and present)
gem 'mandrill-api' # official Mandrill's gem

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Environment-specific gems

group :development do
  gem 'annotate' # adds the list of fields in each table to the models and test files
  gem 'better_errors' # gives more useful error report in the browser
  gem 'bullet' # Warnings about n+1 and other query problems
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'powder'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug' # halts code so you can experiment with it
  #gem 'pry-remote'
  gem 'hirb'
  gem 'pry-stack_explorer'
  gem 'factory_bot_rails' #A library for setting up Ruby objects as test data
  gem 'rspec-rails' # our core testing environment
  gem 'ultrahook' # allows incoming webhooks from stripe
end

group :test do
  gem 'database_cleaner' # tidies up the test database
  gem 'guard-rspec' # Guard watches for any changed file and reruns that files tests
  gem 'rspec_junit_formatter'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers' # adds more RSpec test types
  gem 'shoulda-callback-matchers' # adds more RSpec test types
  gem 'simplecov', require: false
  gem 'webmock' # stub http requestes
  gem 'webrat' # Runs tests in a "headless" browser
  gem 'launchy'
  gem 'timecop'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'rubocop-rspec'
end

group :staging, :production do
  gem 'execjs'
  gem 'newrelic_rpm' # support for the newrelic.com performance monitoring service
  #gem 'rails_serve_static_assets' # needed for Heroku
  #gem 'rails_12factor' # needed for Heroku
  gem 'mini_racer', platforms: :ruby
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#############################################
## Optional things to think about later on ##
#############################################

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use debugger
# gem 'debugger', group: [:development, :test]

require "erb"
require "yaml"

local_env_file = File.join(File.dirname(__FILE__), "config/local_env.yml")
if File.exist?(local_env_file)
  YAML.load(File.open(local_env_file)).each do |key, value|
    ENV[key.to_s] = value
  end
end