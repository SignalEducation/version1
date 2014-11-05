require 'rails_helper'

RSpec.describe 'course_modules/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @institution = FactoryGirl.create(:institution)
    @exam_level = FactoryGirl.create(:exam_level)
    @exam_section = FactoryGirl.create(:exam_section)
    @tutor = FactoryGirl.create(:tutor)
    temp_course_modules = FactoryGirl.create_list(:course_module, 2, institution_id: @institution.id, exam_level_id: @exam_level.id, exam_section_id: @exam_section.id, tutor_id: @tutor.id)
    @course_modules = CourseModule.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of course_modules' do
    render
    expect(rendered).to match(/#{@course_modules.first.institution.name.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.exam_level.name.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.exam_section.name.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.name.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.name_url.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.description.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.tutor.name.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.sorting_order.to_s}/)
    expect(rendered).to match(/#{@course_modules.first.estimated_time_in_seconds.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
