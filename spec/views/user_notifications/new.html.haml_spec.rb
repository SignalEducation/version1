require 'rails_helper'

RSpec.describe 'user_notifications/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:user)
    @users = User.all
    x = FactoryGirl.create(:forum_topic)
    @forum_topics = ForumTopic.all
    x = FactoryGirl.create(:forum_post)
    @forum_posts = ForumPost.all
    x = FactoryGirl.create(:tutor)
    @tutors = Tutor.all
    x = FactoryGirl.create(:blog_post)
    @blog_posts = BlogPost.all
    @user_notification = FactoryGirl.build(:user_notification)
  end

  it 'renders edit user_notification form' do
    render
    assert_select 'form[action=?][method=?]', user_notifications_path, 'post' do
      assert_select 'select#user_notification_user_id[name=?]', 'user_notification[user_id]'
      assert_select 'input#user_notification_subject_line[name=?]', 'user_notification[subject_line]'
      assert_select 'textarea#user_notification_content[name=?]', 'user_notification[content]'
      assert_select 'input#user_notification_email_required[name=?]', 'user_notification[email_required]'
      assert_select 'input#user_notification_email_sent_at[name=?]', 'user_notification[email_sent_at]'
      assert_select 'input#user_notification_unread[name=?]', 'user_notification[unread]'
      assert_select 'input#user_notification_destroyed_at[name=?]', 'user_notification[destroyed_at]'
      assert_select 'input#user_notification_message_type[name=?]', 'user_notification[message_type]'
      assert_select 'select#user_notification_forum_topic_id[name=?]', 'user_notification[forum_topic_id]'
      assert_select 'select#user_notification_forum_post_id[name=?]', 'user_notification[forum_post_id]'
      assert_select 'select#user_notification_tutor_id[name=?]', 'user_notification[tutor_id]'
      assert_select 'input#user_notification_falling_behind[name=?]', 'user_notification[falling_behind]'
      assert_select 'select#user_notification_blog_post_id[name=?]', 'user_notification[blog_post_id]'
    end
  end
end
