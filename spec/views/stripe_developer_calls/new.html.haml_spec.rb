require 'rails_helper'

RSpec.describe 'stripe_developer_calls/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:user)
    @users = User.all
    @stripe_developer_call = FactoryGirl.build(:stripe_developer_call)
  end

  xit 'renders edit stripe_developer_call form' do
    render
    assert_select 'form[action=?][method=?]', stripe_developer_calls_path, 'post' do
      assert_select 'select#stripe_developer_call_user_id[name=?]', 'stripe_developer_call[user_id]'
      assert_select 'textarea#stripe_developer_call_params_received[name=?]', 'stripe_developer_call[params_received]'
      assert_select 'input#stripe_developer_call_prevent_delete[name=?]', 'stripe_developer_call[prevent_delete]'
    end
  end
end
