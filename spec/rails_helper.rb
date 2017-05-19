require 'simplecov'
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'       # suggested by stack overflow
#require 'rspec/autorun'
require 'authlogic/test_case'     # required for Authlogic
include Authlogic::TestCase       # required for Authlogic
require 'support/dry_specs'       # our handy way of doing lots of repetitive tests
require 'support/feature_specs'   # shortcuts for our feature tests
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'database_cleaner'
require 'support/database_cleaner' # configuration of database_cleaner
require 'sidekiq/testing'
require 'support/fake_stripe'
Sidekiq::Testing.inline! # makes background jobs run immediately

# Add additional requires below this line. Rails is not loaded until this point!

# Added the below block to ensure that updated shoulda/matchers gem works correctly with rspec
require "bundler/setup"
::Bundler.require(:default, :test)
require "shoulda/matchers"
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  #
  Capybara.javascript_driver = :selenium

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
  config.formatter = :documentation
end

# see https://github.com/rspec/rspec-rails/issues/255
# and https://github.com/dp90219/jianshu-patients/commit/4148918912f11bf7c2bc1f858f07ba1e20e3b247

class ActionView::TestCase::TestController
  def default_url_options(options={})
    { locale: I18n.default_locale }
  end
end

class ActionDispatch::Routing::RouteSet
  def default_url_options(options={})
    { locale: I18n.default_locale }
  end
end

Time::DATE_FORMATS[:simple] = I18n.t('controllers.application.date_formats.simple')
Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')


