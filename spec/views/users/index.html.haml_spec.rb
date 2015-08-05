require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user_group = FactoryGirl.create(:user_group)
    @corporate_customer = FactoryGirl.create(:corporate_customer)
    temp_users = FactoryGirl.create_list(:user, 2, user_group_id: @user_group.id, stripe_customer_id: @stripe_customer.id, corporate_customer_id: @corporate_customer.id)
    @users = User.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of users' do
    render
    expect(rendered).to match(/#{@users.first.email.to_s}/)
    expect(rendered).to match(/#{@users.first.first_name.to_s}/)
    expect(rendered).to match(/#{@users.first.last_name.to_s}/)
    expect(rendered).to match(/#{@users.first.login_count.to_s}/)
    expect(rendered).to match(/#{@users.first.failed_login_count.to_s}/)
    expect(rendered).to match(/#{@users.first.last_request_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@users.first.current_login_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@users.first.last_login_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@users.first.current_login_ip.to_s}/)
    expect(rendered).to match(/#{@users.first.last_login_ip.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@users.first.user_group.name.to_s}/)
    expect(rendered).to match(/#{@users.first.password_reset_requested_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@users.first.password_reset_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@users.first.stripe_customer_id.to_s}/)
    expect(rendered).to match(/#{@users.first.corporate_customer.name.to_s}/)
    expect(rendered).to match(/#{@users.first.operational_email_frequency.to_s}/)
    expect(rendered).to match(/#{@users.first.study_plan_notifications_email_frequency.to_s}/)
    expect(rendered).to match(/#{@users.first.falling_behind_email_alert_frequency.to_s}/)
    expect(rendered).to match(/#{@users.first.marketing_email_frequency.to_s}/)
    expect(rendered).to match(/#{@users.first.marketing_email_permission_given_at.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@users.first.blog_notification_email_frequency.to_s}/)
    expect(rendered).to match(/#{@users.first.forum_notification_email_frequency.to_s}/)
  end
end
