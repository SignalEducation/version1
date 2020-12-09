# frozen_string_literal: true

class Rack::Attack
  Rack::Attack.throttle("requests by ip", limit: 30, period: 1.minute) do |request|
    request.ip
  end

  Rack::Attack.blocklist('blocked bad request') do |req|
    req.path == '/d/a/g' && req.post?
  end
end
