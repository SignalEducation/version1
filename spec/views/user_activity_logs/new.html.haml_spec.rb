require 'rails_helper'

RSpec.describe 'user_activity_logs/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:user)
    @users = User.all
    x = FactoryGirl.create(:session)
    @sessions = Session.all
    @user_activity_log = FactoryGirl.build(:user_activity_log)
  end

  xit 'renders edit user_activity_log form' do
    render
    assert_select 'form[action=?][method=?]', user_activity_logs_path, 'post' do
      assert_select 'select#user_activity_log_user_id[name=?]', 'user_activity_log[user_id]'
      assert_select 'select#user_activity_log_session_id[name=?]', 'user_activity_log[session_id]'
      assert_select 'input#user_activity_log_signed_in[name=?]', 'user_activity_log[signed_in]'
      assert_select 'input#user_activity_log_original_uri[name=?]', 'user_activity_log[original_uri]'
      assert_select 'input#user_activity_log_controller_name[name=?]', 'user_activity_log[controller_name]'
      assert_select 'input#user_activity_log_action_name[name=?]', 'user_activity_log[action_name]'
      assert_select 'textarea#user_activity_log_params[name=?]', 'user_activity_log[params]'
      assert_select 'input#user_activity_log_alert_level[name=?]', 'user_activity_log[alert_level]'
    end
  end
end
