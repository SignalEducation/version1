require 'rails_helper'

RSpec.describe 'groups/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject = FactoryGirl.create(:subject)
    temp_groups = FactoryGirl.create_list(:group, 2, subject_id: @subject.id)
    @groups = Group.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of groups' do
    render
    expect(rendered).to match(/#{@groups.first.name.to_s}/)
    expect(rendered).to match(/#{@groups.first.name_url.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@groups.first.sorting_order.to_s}/)
    expect(rendered).to match(/#{@groups.first.description.to_s}/)
    expect(rendered).to match(/#{@groups.first.subject.name.to_s}/)
  end
end
