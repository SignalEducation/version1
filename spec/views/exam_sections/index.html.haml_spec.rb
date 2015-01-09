require 'rails_helper'

RSpec.describe 'exam_sections/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @qualification = FactoryGirl.create(:qualification)
    @exam_level = FactoryGirl.create(:exam_level, qualification_id: @qualification.id)
    @exam_levels = ExamLevel.all_in_order
    temp_exam_sections = FactoryGirl.create_list(:exam_section, 2, exam_level_id: @exam_level.id)
    @exam_sections = ExamSection.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of exam_sections' do
    render
    expect(rendered).to match(/#{@exam_sections.first.name.to_s}/)
    expect(rendered).to match(/#{@exam_sections.first.name_url.to_s}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
