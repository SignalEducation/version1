require 'rails_helper'

RSpec.describe 'groups/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @group = FactoryGirl.create(:group)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@group.name}/)
    expect(rendered).to match(/#{@group.name_url}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@group.sorting_order}/)
    expect(rendered).to match(/#{@group.description}/)
  end
end
