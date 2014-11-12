# == Schema Information
#
# Table name: user_notifications
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  subject_line   :string(255)
#  content        :text
#  email_required :boolean          default(FALSE), not null
#  email_sent_at  :datetime
#  unread         :boolean          default(TRUE), not null
#  destroyed_at   :datetime
#  message_type   :string(255)
#  forum_topic_id :integer
#  forum_post_id  :integer
#  tutor_id       :integer
#  falling_behind :boolean          not null
#  blog_post_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#

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
