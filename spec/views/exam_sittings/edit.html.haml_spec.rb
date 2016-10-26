require 'rails_helper'

RSpec.describe 'exam_sittings/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:subject_course)
    @subject_courses = SubjectCourse.all
    @exam_sitting = FactoryGirl.create(:exam_sitting)
  end

  it 'renders new exam_sitting form' do
    render
    assert_select 'form[action=?][method=?]', exam_sitting_path(id: @exam_sitting.id), 'post' do
      assert_select 'input#exam_sitting_name[name=?]', 'exam_sitting[name]'
      assert_select 'select#exam_sitting_subject_course_id[name=?]', 'exam_sitting[subject_course_id]'
      assert_select 'input#exam_sitting_date[name=?]', 'exam_sitting[date]'
    end
  end
end
