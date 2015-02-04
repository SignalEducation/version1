require 'rails_helper'

RSpec.describe 'subject_areas/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_subject_areas = FactoryGirl.create_list(:subject_area, 2)
    @subject_areas = SubjectArea.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of subject_areas' do
    render
    expect(rendered).to match(/#{@subject_areas.first.name.to_s}/)
    expect(rendered).to match(/#{@subject_areas.first.name_url.to_s}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
