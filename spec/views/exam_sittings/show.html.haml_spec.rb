require 'rails_helper'

RSpec.describe 'exam_sittings/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_course = FactoryGirl.create(:subject_course)
    @exam_sitting = FactoryGirl.create(:exam_sitting, subject_course_id: @subject_course.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@exam_sitting.name}/)
    expect(rendered).to match(/#{@exam_sitting.subject_course.name}/)
    expect(rendered).to match(/#{@exam_sitting.date}/)
  end
end
