require 'rails_helper'

RSpec.describe 'subject_areas/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_area = FactoryGirl.create(:subject_area)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@subject_area.name}/)
    expect(rendered).to match(/#{@subject_area.name_url}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
