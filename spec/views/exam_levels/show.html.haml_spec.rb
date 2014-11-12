require 'rails_helper'

RSpec.describe 'exam_levels/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @institution = FactoryGirl.create(:institution)
    @exam_level = FactoryGirl.create(:exam_level)
    @exam_section = FactoryGirl.create(:exam_section)
    @tutor = FactoryGirl.create(:tutor)
    @course_module = FactoryGirl.create(:course_module, institution_id: @institution.id, exam_level_id: @exam_level.id, exam_section_id: @exam_section.id, tutor_id: @tutor.id)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@course_module.institution.name}/)
    expect(rendered).to match(/#{@course_module.exam_level.name}/)
    expect(rendered).to match(/#{@course_module.exam_section.name}/)
    expect(rendered).to match(/#{@course_module.name}/)
    expect(rendered).to match(/#{@course_module.name_url}/)
    expect(rendered).to match(/#{@course_module.description}/)
    expect(rendered).to match(/#{@course_module.tutor.name}/)
    expect(rendered).to match(/#{@course_module.estimated_time_in_seconds}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
