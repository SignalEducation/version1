RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
    FactoryGirl.reload
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    begin
      DatabaseCleaner.clean
    rescue Exception => e
      sleep 1
      DatabaseCleaner.clean
    end
  end

end
