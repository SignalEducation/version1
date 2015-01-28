require 'rails_helper'

RSpec.describe 'institutions/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_areas = FactoryGirl.create_list(:subject_area, 3)
    @subject_area = @subject_areas.first
    temp_institutions = FactoryGirl.create_list(:institution, 2, subject_area_id: @subject_area.id)
    @institutions = Institution.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of institutions' do
    render
    expect(rendered).to match(/#{@institutions.first.name.to_s}/)
    expect(rendered).to match(/#{@institutions.first.short_name.to_s}/)
    expect(rendered).to match(/#{@institutions.first.feedback_url.to_s}/)
    expect(rendered).to match(/#{@institutions.first.help_desk_url.to_s}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
