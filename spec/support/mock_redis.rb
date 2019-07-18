# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    allow(Redis).to receive(:new).and_return(MockRedis.new)
  end
end
