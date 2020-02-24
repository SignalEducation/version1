# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    Excon.defaults[:mock] = true
    Excon.stub({}, body: '{}', status: 200) # stubs any request to return an empty JSON string
  end
end
