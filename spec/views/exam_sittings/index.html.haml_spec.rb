require 'rails_helper'

RSpec.describe 'exam_sittings/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_course = FactoryGirl.create(:subject_course)
    temp_exam_sittings = FactoryGirl.create_list(:exam_sitting, 2, subject_course_id: @subject_course.id)
    @exam_sittings = ExamSitting.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of exam_sittings' do
    render
    expect(rendered).to match(/#{@exam_sittings.first.name.to_s}/)
    expect(rendered).to match(/#{@exam_sittings.first.subject_course.name.to_s}/)
    expect(rendered).to match(/#{@exam_sittings.first.date.to_s}/)
  end
end
