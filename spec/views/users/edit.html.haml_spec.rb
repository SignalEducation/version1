require 'rails_helper'

RSpec.describe 'users/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:user_group)
    @user_groups = UserGroup.all
    x = FactoryGirl.create(:corporate_customer)
    @corporate_customers = CorporateCustomer.all
    x = FactoryGirl.create(:corporate_customer_user_group)
    @corporate_customer_user_groups = CorporateCustomerUserGroup.all
    @user = FactoryGirl.create(:user)
  end

  xit 'renders new user form' do
    render
    assert_select 'form[action=?][method=?]', user_path(id: @user.id), 'post' do
      assert_select 'input#user_email[name=?]', 'user[email]'
      assert_select 'input#user_first_name[name=?]', 'user[first_name]'
      assert_select 'input#user_last_name[name=?]', 'user[last_name]'
      assert_select 'input#user_password[name=?]', 'user[password]'
      assert_select 'input#user_password_confirmation[name=?]', 'user[password_confirmation]'
      assert_select 'input#user_active[name=?]', 'user[active]'
      assert_select 'select#user_user_group_id[name=?]', 'user[user_group_id]'
      assert_select 'select#user_corporate_customer_id[name=?]', 'user[corporate_customer_id]'
      assert_select 'select#user_corporate_customer_user_group_id[name=?]', 'user[corporate_customer_user_group_id]'
      assert_select 'input#user_operational_email_frequency[name=?]', 'user[operational_email_frequency]'
      assert_select 'input#user_study_plan_notifications_email_frequency[name=?]', 'user[study_plan_notifications_email_frequency]'
      assert_select 'input#user_falling_behind_email_alert_frequency[name=?]', 'user[falling_behind_email_alert_frequency]'
      assert_select 'input#user_marketing_email_frequency[name=?]', 'user[marketing_email_frequency]'
      assert_select 'input#user_marketing_email_permission_given_at[name=?]', 'user[marketing_email_permission_given_at]'
      assert_select 'input#user_blog_notification_email_frequency[name=?]', 'user[blog_notification_email_frequency]'
      assert_select 'input#user_forum_notification_email_frequency[name=?]', 'user[forum_notification_email_frequency]'
    end
  end
end
