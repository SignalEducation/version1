require 'rails_helper'

RSpec.describe 'user_activity_logs/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @session = FactoryGirl.create(:session)
    @user_activity_log = FactoryGirl.create(:user_activity_log, user_id: @user.id, session_id: @session.id)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@user_activity_log.user.name}/)
    expect(rendered).to match(/#{@user_activity_log.session.name}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@user_activity_log.original_uri}/)
    expect(rendered).to match(/#{@user_activity_log.controller_name}/)
    expect(rendered).to match(/#{@user_activity_log.action_name}/)
    expect(rendered).to match(/#{@user_activity_log.params}/)
    expect(rendered).to match(/#{@user_activity_log.alert_level}/)
  end
end
