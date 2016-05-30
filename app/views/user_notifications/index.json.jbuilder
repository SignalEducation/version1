json.array!(@user_notifications) do |user_notification|
  json.extract! user_notification, :id, :user_id, :subject_line, :content, :email_required, :email_sent_at, :unread, :destroyed_at, :message_type, :tutor_id, :falling_behind, :blog_post_id
  json.url user_notification_url(user_notification, format: :json)
end
