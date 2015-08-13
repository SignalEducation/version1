require 'rails_helper'

RSpec.describe 'corporate_students/new', type: :view do
  before(:each) do
    @corporate_student = FactoryGirl.build(:corporate_student)
  end

  it 'renders edit corporate_student form' do
    render
    assert_select 'form[action=?][method=?]', corporate_students_path, 'post' do
      assert_select 'input#corporate_student_index[name=?]', 'corporate_student[index]'
      assert_select 'input#corporate_student_new[name=?]', 'corporate_student[new]'
      assert_select 'input#corporate_student_create[name=?]', 'corporate_student[create]'
    end
  end
end
