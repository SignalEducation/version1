source 'https://rubygems.org'

ruby '2.2.2'
gem 'rails', '4.2.1'

# Core gems - common to all environments
gem 'airbrake'
gem 'authlogic', '~> 3.4.3'
gem 'scrypt' # S-Crypt for Authlogic
gem 'autoprefixer-rails', '~> 5.0.0.1' # required by bootstrap-sass
#gem 'aws-sdk' # enables AWS functionality - use with AWS::...
gem 'aws-sdk-v1' # enables AWS functionality - use with AWS::...
gem 'aws-sdk-core' # v2 of AWS SDK - use with Aws::..., not AWS::...
#gem 'aws-s3' # grants timeout-able URLs
gem 'bootstrap-sass', '~> 3.3.2' # loads Twitter Bootstrap UI framework
gem 'bootstrap-datepicker-rails' # enables datepicker objects in the browser
gem 'browser' # user-agent detection
gem 'chart-js-rails' #Graphs
gem 'coffee-rails', '~> 4.0.0' # enables CoffeeScript (abbreviated javascript)
gem 'figaro' # management of ENV vars
gem 'geocoder' # a public API for geo-locating IP addresses
gem 'haml-rails' # a replacement system for HTML
gem 'intercom-rails', '~> 0.2.27' # communicate with Intercom.io
gem 'jbuilder', '~> 2.0' # https://github.com/rails/jbuilder
gem 'jquery-rails' # include jQuery for Rails
gem 'jquery-ui-rails' # include jQuery UI for Rails
gem 'le' # logEntries.com
gem 'mathjax-rails' # maths functions in the UI
gem 'paperclip', '~> 4.2.1' # for uploading files (works with RemotiPart)
gem 'mailchimp-api', '~> 2.0.4'
gem 'mixpanel-ruby', '~> 2.1' # support for MixPanel
gem 'multipart-post' #To allow uploading wistia api
gem 'pg' # PostgreSQL database engine
gem 'protected_attributes' # allows 'attr_accessible' in Rails 4's models
gem 'rack-attack'
gem 'remotipart' # enables file upload in forms that work using AJAX
gem 'sass-rails', '~> 4.0.3' # Use SCSS for stylesheets
gem 'sidekiq', require: %w(sidekiq sidekiq/web)
        # background processor for tasks that can be run 'later' or take too long
        # Requires Redis NoSQL datastore
gem 'sinatra' # needed for sidekiq's web UI
gem 'stripe', '=1.16.0' #, git: 'https://github.com/stripe/stripe-ruby'
# support for Stripe.com payment processing
#gem 'turbolinks' # speeds up page loading - has negative side-effects
gem 'uglifier', '>= 1.3.0' # compresses Javascript when sending it to users in production
gem 'utf8-cleaner' # removes illegal characters from inbound requests
gem 'will_paginate' # manage long web pages
gem 'will_paginate-bootstrap' # adds Bootstrap3 support to will_paginate
gem 'wistia-api' #Video player data api gem, allows retrieval of data on videos and projects
gem 'font-awesome-rails' # Font Awesome with lot of useful icons
gem 'zeroclipboard-rails' # For copying referral code URL to clipboard (works only if Flash is enabled and present)
gem 'mandrill-api' # official Mandrill's gem

# Environment-specific gems

group :development do
  gem 'annotate' # adds the list of fields in each table to the models and test files
  gem 'better_errors' # gives more useful error report in the browser
  gem 'binding_of_caller' # allows interactivity in the browser during errors
  gem 'bullet' # Warnings about n+1 and other query problems
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-passenger', '0.0.2'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'spring' # Spring speeds up development by keeping your application running
          # in the background. Read more: https://github.com/rails/spring
end

group :development, :test do
  gem 'pry-byebug' # halts code so you can experiment with it
  gem 'hirb'
  gem 'pry-stack_explorer'
  gem 'capybara' # Runs tests in a browser
  gem 'capybara-webkit'
  gem 'factory_girl_rails' # FactoryGirl generates fake objects
  gem 'poltergeist'
  gem 'rspec-rails' # our core testing environment
  gem 'selenium-webdriver', '>=2.45.0'
  gem 'thin' # new web server
end

group :test do
  # https://semaphoreapp.com/blog/2013/08/14/setting-up-bdd-stack-on-a-new-rails-4-application.html
  gem 'database_cleaner' # tidies up the test database
  gem 'guard-rspec' # Guard watches for any changed file and reruns that files tests
  gem 'shoulda-matchers' # adds more RSpec test types
  gem 'shoulda-callback-matchers' # adds more RSpec test types
  gem 'simplecov', require: false
  gem 'stripe-ruby-mock', '~> 2.0.2', require: 'stripe_mock'
  gem 'webrat' # Runs tests in a "headless" browser
end

group :staging do

end

group :staging, :production do
  gem 'execjs'
  gem 'newrelic_rpm' # support for the newrelic.com performance monitoring service
  #gem 'rails_serve_static_assets' # needed for Heroku
  #gem 'rails_12factor' # needed for Heroku
  gem 'therubyracer', platforms: :ruby
end

group :production do
end

#############################################
## Optional things to think about later on ##
#############################################

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
