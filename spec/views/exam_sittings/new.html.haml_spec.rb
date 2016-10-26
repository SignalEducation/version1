require 'rails_helper'

RSpec.describe 'exam_sittings/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:subject_course)
    @subject_courses = SubjectCourse.all
    @exam_sitting = FactoryGirl.build(:exam_sitting)
  end

  it 'renders edit exam_sitting form' do
    render
    assert_select 'form[action=?][method=?]', exam_sittings_path, 'post' do
      assert_select 'input#exam_sitting_name[name=?]', 'exam_sitting[name]'
      assert_select 'select#exam_sitting_subject_course_id[name=?]', 'exam_sitting[subject_course_id]'
      assert_select 'input#exam_sitting_date[name=?]', 'exam_sitting[date]'
    end
  end
end
