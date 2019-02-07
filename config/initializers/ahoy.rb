class Ahoy::Store < Ahoy::DatabaseStore
  protected
  def visit_model
    ::Visit
  end
end

# set to true for JavaScript tracking
Ahoy.api = false

# better user agent parsing
Ahoy.user_agent_parser = :device_detector

# better bot detection
Ahoy.bot_detection_version = 2
