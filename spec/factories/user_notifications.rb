FactoryGirl.define do
  factory :user_notification do
    user_id 1
    subject_line "MyString"
    content "MyText"
    email_required false
    email_sent_at "2014-11-12 09:30:33"
    unread false
    destroyed_at "2014-11-12 09:30:33"
    message_type "MyString"
    forum_topic_id 1
    forum_post_id 1
    tutor_id 1
    falling_behind false
    blog_post_id 1
  end

end
