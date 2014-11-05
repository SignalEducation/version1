require 'rails_helper'

RSpec.describe 'qualifications/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @institution = FactoryGirl.create(:institution)
    @qualification = FactoryGirl.create(:qualification, institution_id: @institution.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@qualification.institution.name}/)
    expect(rendered).to match(/#{@qualification.name}/)
    expect(rendered).to match(/#{@qualification.name_url}/)
    expect(rendered).to match(/#{@qualification.sorting_order}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@qualification.cpd_hours_required_per_year}/)
  end
end
