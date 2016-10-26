require 'rails_helper'

RSpec.describe 'user_exam_sittings/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @exam_sitting = FactoryGirl.create(:exam_sitting)
    @subject_course = FactoryGirl.create(:subject_course)
    temp_user_exam_sittings = FactoryGirl.create_list(:user_exam_sitting, 2, user_id: @user.id, exam_sitting_id: @exam_sitting.id, subject_course_id: @subject_course.id)
    @user_exam_sittings = UserExamSitting.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of user_exam_sittings' do
    render
    expect(rendered).to match(/#{@user_exam_sittings.first.user.name.to_s}/)
    expect(rendered).to match(/#{@user_exam_sittings.first.exam_sitting.name.to_s}/)
    expect(rendered).to match(/#{@user_exam_sittings.first.subject_course.name.to_s}/)
    expect(rendered).to match(/#{@user_exam_sittings.first.date.to_s}/)
  end
end
