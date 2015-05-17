# == Schema Information
#
# Table name: user_notifications
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  subject_line   :string
#  content        :text
#  email_required :boolean          default(FALSE), not null
#  email_sent_at  :datetime
#  unread         :boolean          default(TRUE), not null
#  destroyed_at   :datetime
#  message_type   :string
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
    email_sent_at { Time.now - 1.day }
    unread false
    message_type 'blog'
    forum_topic_id 1
    forum_post_id 1
    tutor_id 1
    falling_behind false
    blog_post_id 1

    factory :deleted_user_notification do
      destroyed_at { Time.now + 1.day }
    end
  end

end
