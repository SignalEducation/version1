# frozen_string_literal: true

ENV['ASSET_PRECOMPILE_DONE'] = nil

RSpec.configure do |config|
  config.before(:suite) do
    Webpacker.compile
  end
end
