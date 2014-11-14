require 'rails_helper'

RSpec.describe 'user_notifications/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @forum_topic = FactoryGirl.create(:forum_topic)
    @forum_post = FactoryGirl.create(:forum_post)
    @tutor = FactoryGirl.create(:tutor)
    @blog_post = FactoryGirl.create(:blog_post)
    temp_user_notifications = FactoryGirl.create_list(:user_notification, 2, user_id: @user.id, forum_topic_id: @forum_topic.id, forum_post_id: @forum_post.id, tutor_id: @tutor.id, blog_post_id: @blog_post.id)
    @user_notifications = UserNotification.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of user_notifications' do
    render
    expect(rendered).to match(/#{@user_notifications.first.user.name.to_s}/)
    expect(rendered).to match(/#{@user_notifications.first.subject_line.to_s}/)
    expect(rendered).to match(/#{@user_notifications.first.content.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_notifications.first.email_sent_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_notifications.first.destroyed_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@user_notifications.first.message_type.to_s}/)
    expect(rendered).to match(/#{@user_notifications.first.forum_topic.name.to_s}/)
    expect(rendered).to match(/#{@user_notifications.first.forum_post.name.to_s}/)
    expect(rendered).to match(/#{@user_notifications.first.tutor.name.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_notifications.first.blog_post.name.to_s}/)
  end
end
