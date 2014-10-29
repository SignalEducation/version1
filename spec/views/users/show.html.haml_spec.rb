require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user_group = FactoryGirl.create(:user_group)
    @corporate_customer = FactoryGirl.create(:corporate_customer)
    @corporate_customer_user_group = FactoryGirl.create(:corporate_customer_user_group)
    @user = FactoryGirl.create(:user, user_group_id: @user_group.id, stripe_customer_id: @stripe_customer.id, corporate_customer_id: @corporate_customer.id, corporate_customer_user_group_id: @corporate_customer_user_group.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@user.email}/)
    expect(rendered).to match(/#{@user.full_name}/)
    expect(rendered).to match(/#{@user.login_count}/)
    expect(rendered).to match(/#{@user.failed_login_count}/)
    expect(rendered).to match(/#{@user.last_request_at.to_s(:standard)}/)
    expect(rendered).to match(/#{@user.current_login_at.to_s(:standard)}/)
    expect(rendered).to match(/#{@user.last_login_at.to_s(:standard)}/)
    expect(rendered).to match(/#{@user.current_login_ip}/)
    expect(rendered).to match(/#{@user.last_login_ip}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user.user_group.name}/)
    expect(rendered).to match(/#{@user.password_reset_requested_at.to_s(:standard)}/)
    expect(rendered).to match(/#{@user.password_reset_token}/)
    expect(rendered).to match(/#{@user.password_reset_at.to_s(:standard)}/)
    expect(rendered).to match(/#{@user.stripe_customer_id}/)
    expect(rendered).to match(/#{@user.corporate_customer.name}/)
    expect(rendered).to match(/#{@user.corporate_customer_user_group.name}/)
    expect(rendered).to match(/#{@user.operational_email_frequency}/)
    expect(rendered).to match(/#{@user.study_plan_notifications_email_frequency}/)
    expect(rendered).to match(/#{@user.falling_behind_email_alert_frequency}/)
    expect(rendered).to match(/#{@user.marketing_email_frequency}/)
    expect(rendered).to match(/#{@user.marketing_email_permission_given_at.to_s(:standard)}/)
    expect(rendered).to match(/#{@user.blog_notification_email_frequency}/)
    expect(rendered).to match(/#{@user.forum_notification_email_frequency}/)
  end
end
