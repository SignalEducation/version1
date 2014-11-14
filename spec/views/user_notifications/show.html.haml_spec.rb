require 'rails_helper'

RSpec.describe 'user_notifications/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:individual_student_user)
    #@forum_topic = FactoryGirl.create(:forum_topic)
    #@forum_post = FactoryGirl.create(:forum_post)
    @tutor = FactoryGirl.create(:tutor_user)
    #@blog_post = FactoryGirl.create(:blog_post)
    @user_notification = FactoryGirl.create(:user_notification, user_id: @user.id, tutor_id: @tutor.id)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@user_notification.user.name}/)
    expect(rendered).to match(/#{@user_notification.subject_line}/)
    expect(rendered).to match(/#{@user_notification.content}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_notification.email_sent_at.to_s(:standard)}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_notification.destroyed_at.to_s(:standard)}/)
    expect(rendered).to match(/#{@user_notification.message_type}/)
    expect(rendered).to match(/#{@user_notification.forum_topic.name}/)
    expect(rendered).to match(/#{@user_notification.forum_post.name}/)
    expect(rendered).to match(/#{@user_notification.tutor.name}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_notification.blog_post.name}/)
  end
end
