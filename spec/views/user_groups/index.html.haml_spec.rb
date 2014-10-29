require 'rails_helper'

RSpec.describe 'user_groups/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_user_groups = FactoryGirl.create_list(:user_group, 2)
    @user_groups = UserGroup.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of user_groups' do
    render
    expect(rendered).to match(/#{@user_groups.first.name.to_s}/)
    expect(rendered).to match(/#{@user_groups.first.description.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
