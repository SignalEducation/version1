require 'rails_helper'

RSpec.describe 'institutions/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_area = FactoryGirl.create(:subject_area)
    @institution = FactoryGirl.create(:institution, subject_area_id: @subject_area.id)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@institution.name}/)
    expect(rendered).to match(/#{@institution.short_name}/)
    expect(rendered).to match(/#{@institution.name_url}/)
    expect(rendered).to match(/#{@institution.description}/)
    expect(rendered).to match(/#{@institution.feedback_url}/)
    expect(rendered).to match(/#{@institution.help_desk_url}/)
    expect(rendered).to match(/#{@institution.subject_area.name}/)
    expect(rendered).to match(/#{@institution.sorting_order}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
