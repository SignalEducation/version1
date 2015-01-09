require 'rails_helper'

RSpec.describe 'qualifications/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @institution = FactoryGirl.create(:institution)
    @institutions = Institution.all_in_order
    temp_qualifications = FactoryGirl.create_list(:qualification, 2, institution_id: @institution.id)
    @qualifications = Qualification.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of qualifications' do
    render
    expect(rendered).to match(/#{@qualifications.first.name.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@qualifications.first.cpd_hours_required_per_year.to_s}/)
  end
end
