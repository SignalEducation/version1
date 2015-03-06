require 'rails_helper'

RSpec.describe 'stripe_developer_calls/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    temp_stripe_developer_calls = FactoryGirl.create_list(:stripe_developer_call, 2, user_id: @user.id)
    @stripe_developer_calls = StripeDeveloperCall.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of stripe_developer_calls' do
    render
    expect(rendered).to match(/#{@stripe_developer_calls.first.user.name.to_s}/)
    expect(rendered).to match(/#{@stripe_developer_calls.first.params_received.to_s}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
