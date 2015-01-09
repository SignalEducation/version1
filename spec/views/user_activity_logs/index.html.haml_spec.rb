require 'rails_helper'

RSpec.describe 'user_activity_logs/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @session = FactoryGirl.create(:session)
    temp_user_activity_logs = FactoryGirl.create_list(:user_activity_log, 2, user_id: @user.id, session_id: @session.id)
    @user_activity_logs = UserActivityLog.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of user_activity_logs' do
    render
    expect(rendered).to match(/#{@user_activity_logs.first.user.name.to_s}/)
    expect(rendered).to match(/#{@user_activity_logs.first.session.name.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_activity_logs.first.original_uri.to_s}/)
    expect(rendered).to match(/#{@user_activity_logs.first.controller_name.to_s}/)
    expect(rendered).to match(/#{@user_activity_logs.first.action_name.to_s}/)
    expect(rendered).to match(/#{@user_activity_logs.first.params.to_s}/)
    expect(rendered).to match(/#{@user_activity_logs.first.alert_level.to_s}/)
  end
end
