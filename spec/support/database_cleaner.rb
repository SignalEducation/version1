RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
    FactoryBot.reload
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

   # Force the driver to wait till the page finishes loading
  config.after(:each, js: true) do
    current_path.should == current_path
  end

  config.after(:each) do
    DatabaseCleaner.clean
  rescue Exception => e
    sleep 1
    DatabaseCleaner.clean
  end
end
