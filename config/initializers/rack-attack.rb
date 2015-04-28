# Required by the RackAttack gem
class Rack::Attack
  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', limit: 30, period: 2.minutes) do |req|
    req.ip unless req.path.starts_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/login' && req.post?
      req.ip
    end
  end
  throttle('sign_in/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/sign_in' && req.post?
      req.ip
    end
  end
  throttle('sign_in/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/en/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)

  # /login, params[:email]  --  shouldn't go anywhere as we don't respond to it
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/login' && req.post?
      # return the email if present, nil otherwise
      req.params['email'].presence
    end
  end

  # /sign_in, params[:email]
  throttle('sign_in/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/sign_in' && req.post?
      # return the email if present, nil otherwise
      req.params['email'].presence
    end
  end

  # /sign_in, params[:user][:email]
  throttle('sign_in/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/sign_in' && req.post?
      # return the email if present, nil otherwise
      req.params['user']['email'].presence
    end
  end

  # /en/sign_in, params[:email]
  throttle('sign_in/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/en/sign_in' && req.post?
      # return the email if present, nil otherwise
      req.params['email'].presence
    end
  end

  # en/sign_in, params[:user][:email]
  throttle('sign_in/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/en/sign_in' && req.post?
      # return the email if present, nil otherwise
      req.params['user']['email'].presence
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end

  # ### from the Advanced setup suggestions:
  # # After 5 requests with incorrect auth in 1 minute,
  # # block all requests from that IP for 1 hour.
  # Rack::Attack.blacklist('basic auth crackers') do |req|
  #   Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 5, findtime: 1.minute, bantime: 1.hour) do
  #     # Return true if the authorization header not incorrect
  #     auth = Rack::Auth::Basic::Request.new(req.env)
  #     auth.credentials != ['signal', 'MeagherMacRedmond']
  #   end
  # end
end

# Always allow requests from localhost
# (blacklist & throttles are skipped)
Rack::Attack.whitelist('allow from localhost') do |req|
  # Requests are allowed if the return value is truthy
  '127.0.0.1' == req.ip ||
  '109.79.44.36' == req.ip # current Vodafone base station 31AD external IP
end
