RSpec.configure do |config|
  config.before(:suite) do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  config.after(:each) do
    Sidekiq::Worker.drain_all
  end
end
