RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
  config.after(:suite) do
    FileUtils.rm_rf(Dir[Rails.root.join('spec', 'test_files')])
  end
end
