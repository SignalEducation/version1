require 'rails_helper'

RSpec.describe 'groups/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject = FactoryGirl.create(:subject)
    @group = FactoryGirl.create(:group, subject_id: @subject.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@group.name}/)
    expect(rendered).to match(/#{@group.name_url}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@group.sorting_order}/)
    expect(rendered).to match(/#{@group.description}/)
    expect(rendered).to match(/#{@group.subject.name}/)
  end
end
