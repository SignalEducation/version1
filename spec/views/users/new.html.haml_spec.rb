require 'rails_helper'

RSpec.describe 'users/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:user_group)
    @user_groups = UserGroup.all
    x = FactoryGirl.create(:corporate_customer)
    @corporate_customers = CorporateCustomer.all
    @user = FactoryGirl.build(:user)
  end

  xit 'renders edit user form' do
    render
    assert_select 'form[action=?][method=?]', users_path, 'post' do
      assert_select 'input#user_email[name=?]', 'user[email]'
      assert_select 'input#user_first_name[name=?]', 'user[first_name]'
      assert_select 'input#user_last_name[name=?]', 'user[last_name]'
      assert_select 'input#user_crypted_password[name=?]', 'user[crypted_password]'
      assert_select 'input#user_password_salt[name=?]', 'user[password_salt]'
      assert_select 'input#user_persistence_token[name=?]', 'user[persistence_token]'
      assert_select 'input#user_perishable_token[name=?]', 'user[perishable_token]'
      assert_select 'input#user_single_access_token[name=?]', 'user[single_access_token]'
      assert_select 'input#user_login_count[name=?]', 'user[login_count]'
      assert_select 'input#user_failed_login_count[name=?]', 'user[failed_login_count]'
      assert_select 'input#user_last_request_at[name=?]', 'user[last_request_at]'
      assert_select 'input#user_current_login_at[name=?]', 'user[current_login_at]'
      assert_select 'input#user_last_login_at[name=?]', 'user[last_login_at]'
      assert_select 'input#user_current_login_ip[name=?]', 'user[current_login_ip]'
      assert_select 'input#user_last_login_ip[name=?]', 'user[last_login_ip]'
      assert_select 'input#user_active[name=?]', 'user[active]'
      assert_select 'select#user_user_group_id[name=?]', 'user[user_group_id]'
      assert_select 'input#user_password_reset_requested_at[name=?]', 'user[password_reset_requested_at]'
      assert_select 'input#user_password_reset_token[name=?]', 'user[password_reset_token]'
      assert_select 'input#user_password_reset_at[name=?]', 'user[password_reset_at]'
      assert_select 'select#user_stripe_customer_id[name=?]', 'user[stripe_customer_id]'
      assert_select 'select#user_corporate_customer_id[name=?]', 'user[corporate_customer_id]'
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
