require 'rails_helper'

RSpec.describe 'corporate_students/edit', type: :view do
  before(:each) do
    @corporate_student = FactoryGirl.create(:corporate_student)
  end

  it 'renders new corporate_student form' do
    render
    assert_select 'form[action=?][method=?]', corporate_student_path(id: @corporate_student.id), 'post' do
      assert_select 'input#corporate_student_index[name=?]', 'corporate_student[index]'
      assert_select 'input#corporate_student_new[name=?]', 'corporate_student[new]'
      assert_select 'input#corporate_student_create[name=?]', 'corporate_student[create]'
    end
  end
end
