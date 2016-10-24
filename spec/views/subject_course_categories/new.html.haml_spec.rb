require 'rails_helper'

RSpec.describe 'subject_course_categories/new', type: :view do
  before(:each) do
    @subject_course_category = FactoryGirl.build(:subject_course_category)
  end

  it 'renders edit subject_course_category form' do
    render
    assert_select 'form[action=?][method=?]', subject_course_categories_path, 'post' do
      assert_select 'input#subject_course_category_name[name=?]', 'subject_course_category[name]'
      assert_select 'input#subject_course_category_payment_type[name=?]', 'subject_course_category[payment_type]'
      assert_select 'input#subject_course_category_active[name=?]', 'subject_course_category[active]'
      assert_select 'input#subject_course_category_subdomain[name=?]', 'subject_course_category[subdomain]'
    end
  end
end
