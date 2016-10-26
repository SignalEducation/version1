require 'rails_helper'

RSpec.describe 'user_exam_sittings/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @exam_sitting = FactoryGirl.create(:exam_sitting)
    @subject_course = FactoryGirl.create(:subject_course)
    @user_exam_sitting = FactoryGirl.create(:user_exam_sitting, user_id: @user.id, exam_sitting_id: @exam_sitting.id, subject_course_id: @subject_course.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@user_exam_sitting.user.name}/)
    expect(rendered).to match(/#{@user_exam_sitting.exam_sitting.name}/)
    expect(rendered).to match(/#{@user_exam_sitting.subject_course.name}/)
    expect(rendered).to match(/#{@user_exam_sitting.date}/)
  end
end
