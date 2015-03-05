require 'rails_helper'

RSpec.describe 'stripe_developer_calls/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @stripe_developer_call = FactoryGirl.create(:stripe_developer_call, user_id: @user.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@stripe_developer_call.user.name}/)
    expect(rendered).to match(/#{@stripe_developer_call.params_received}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
