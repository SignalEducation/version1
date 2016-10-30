require 'rails_helper'

RSpec.describe 'mock_exams/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:subject_course)
    @subject_courses = SubjectCourse.all
    x = FactoryGirl.create(:product)
    @products = Product.all
    @mock_exam = FactoryGirl.create(:mock_exam)
  end

  it 'renders new mock_exam form' do
    render
    assert_select 'form[action=?][method=?]', mock_exam_path(id: @mock_exam.id), 'post' do
      assert_select 'select#mock_exam_subject_course_id[name=?]', 'mock_exam[subject_course_id]'
      assert_select 'select#mock_exam_product_id[name=?]', 'mock_exam[product_id]'
      assert_select 'input#mock_exam_name[name=?]', 'mock_exam[name]'
      assert_select 'input#mock_exam_sorting_order[name=?]', 'mock_exam[sorting_order]'
    end
  end
end
