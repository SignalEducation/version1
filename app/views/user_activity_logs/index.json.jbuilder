json.array!(@user_activity_logs) do |user_activity_log|
  json.extract! user_activity_log, :id, :user_id, :session_id, :signed_in, :original_uri, :controller_name, :action_name, :params, :alert_level
  json.url user_activity_log_url(user_activity_log, format: :json)
end
