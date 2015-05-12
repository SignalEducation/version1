class Api::BaseController < ApplicationController

  # application_controller stuff that we don't want here...
  skip_before_action :set_locale
  skip_before_action :set_session_stuff
  skip_before_action :process_marketing_tokens
  skip_before_action :log_user_activity

end
