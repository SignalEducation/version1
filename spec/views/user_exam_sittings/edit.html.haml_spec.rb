require 'rails_helper'

RSpec.describe 'user_exam_sittings/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:user)
    @users = User.all
    x = FactoryGirl.create(:exam_sitting)
    @exam_sittings = ExamSitting.all
    x = FactoryGirl.create(:subject_course)
    @subject_courses = SubjectCourse.all
    @user_exam_sitting = FactoryGirl.create(:user_exam_sitting)
  end

  it 'renders new user_exam_sitting form' do
    render
    assert_select 'form[action=?][method=?]', user_exam_sitting_path(id: @user_exam_sitting.id), 'post' do
      assert_select 'select#user_exam_sitting_user_id[name=?]', 'user_exam_sitting[user_id]'
      assert_select 'select#user_exam_sitting_exam_sitting_id[name=?]', 'user_exam_sitting[exam_sitting_id]'
      assert_select 'select#user_exam_sitting_subject_course_id[name=?]', 'user_exam_sitting[subject_course_id]'
      assert_select 'input#user_exam_sitting_date[name=?]', 'user_exam_sitting[date]'
    end
  end
end
