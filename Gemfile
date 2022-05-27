source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git"}

ruby '2.6.5'
gem 'rails', '5.2.2'

# Use Puma as the app server
gem 'puma', '~> 3.12.4'

# Core gems - common to all environments
gem 'airbrake', '~> 9.5'
gem 'authlogic', '~> 6.1.0'
gem 'ahoy_matey', '>= 3.0.0' # visit tracking
gem 'appsignal', '~> 2.11.0'
gem 'uuidtools', '~> 2.1', '>= 2.1.5'
gem 'blazer', '~> 2.1'
gem 'scrypt' # S-Crypt for Authlogic
# gem 'autoprefixer-rails', '~> 5.0.0.1' # required by bootstrap-sass
gem 'aws-sdk-s3', '~> 1'
gem 'slack-ruby-client'
gem 'bootstrap', '~> 4.3.1'
gem 'browser' # user-agent detection
gem 'chart-js-rails', '~> 0.1.6' #Graphs
gem 'coffee-rails', '~> 4.2' # enables CoffeeScript (abbreviated javascript)
gem 'deep_cloneable', '~> 3.0.0'
gem 'dynamic_sitemaps' # Sitemap generation grm
gem 'faraday', '~> 0.15.4'
gem 'geocoder', '~> 1.6' #  a public API for geo-locating IP addresses
gem 'groupdate'
gem 'haml-rails' # a replacement system for HTML
gem 'jbuilder', '~> 2.5' # https://github.com/rails/jbuilder
gem 'jquery-rails' # include jQuery for Rails
gem 'jquery-ui-rails' # include jQuery UI for Rails
gem 'jwt'
gem 'le' # logEntries.com
gem 'mathjax-rails' # maths functions in the UI
gem 'prawn' # PDF creator
gem 'prawn-table', '~> 0.2.2'
gem 'paperclip', '~> 6.1.0' # for uploading files (works with RemotiPart)
gem 'mailchimp-api', '~> 2.0.4'
gem 'momentjs-rails', '>= 2.9.0'
gem 'modernizr-rails'
gem "nokogiri", ">= 1.10.8"
gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'
gem 'multipart-post' #To allow uploading wistia api
gem 'pg' # PostgreSQL database engine
gem 'rack', '2.1.4.1'
gem 'redis-rails' #use redis from AWS Elasticache service
# gem 'redis', '~> 4.0'
gem 'remotipart' # enables file upload in forms that work using AJAX
gem 'remodal-rails'
gem 'rails_real_favicon'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'
gem 'sidekiq', require: %w(sidekiq sidekiq/web)
# background processor for tasks that can be run 'later' or take too long
# Requires Redis NoSQL datastore
gem 'split', require: 'split/dashboard'
gem 'state_machines-activerecord'
gem 'stripe', '~> 4.21.0' #, git: 'https://github.com/stripe/stripe-ruby'
gem 'paypal-sdk-rest', git: "https://github.com/quilligana/PayPal-Ruby-SDK.git", branch: "add-g2-certificate"
gem 'summernote-rails'
gem 'turbolinks', '~> 5' # speeds up page loading - has negative side-effects
gem 'uglifier', '>= 1.3.0' # compresses Javascript when sending it to users in production
gem 'utf8-cleaner' # removes illegal characters from inbound requests
gem 'will_paginate' # manage long web pages
gem 'will_paginate-bootstrap' # adds Bootstrap3 support to will_paginate
gem 'font-awesome-rails' # Font Awesome with lot of useful icons
gem 'mandrill-api' # official Mandrill's gem

gem 'scout_apm'
gem 'rack-mini-profiler'
gem 'flamegraph'
gem 'stackprof'
gem 'recaptcha'
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'webpacker', '~> 4.2'
gem 'rack-cors'
gem 'zendesk_api'

# Environment-specific gems

group :development do
  gem 'annotate' # adds the list of fields in each table to the models and test files
  gem 'better_errors' # gives more useful error report in the browser
  gem 'bullet' # Warnings about n+1 and other query problems
  gem 'lol_dba'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'powder'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'pry', '~> 0.12.2'
  gem 'pry-byebug'
  gem 'hirb'
  gem 'pry-stack_explorer'
  gem 'factory_bot_rails' #A library for setting up Ruby objects as test data
  gem 'rspec-rails' # our core testing environment
  gem 'rubocop', '~> 0.80.1', require: false
  gem 'rubocop-performance', '~> 1.5.2', require: false # rubocop lint
  gem 'rubocop-rails', require: false # rubocop lint
  gem 'rubocop-rspec', require: false
  gem 'ultrahook' # allows incoming webhooks from stripe
  gem 'faker', '~> 2.14.0'
end

group :test do
  gem 'capybara-screenshot'
  gem 'database_cleaner-active_record'
  gem 'guard-rspec' # Guard watches for any changed file and reruns that files tests
  gem 'rspec_junit_formatter'
  gem 'rspec-retry'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers' # adds more RSpec test types
  gem 'shoulda-callback-matchers' # adds more RSpec test types
  gem 'simplecov', require: false
  gem 'webmock' # stub http requestes
  gem 'webrat' # Runs tests in a "headless" browser
  gem 'launchy'
  gem 'timecop'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 4.0'
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
