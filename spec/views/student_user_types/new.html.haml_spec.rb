require 'rails_helper'

RSpec.describe 'student_user_types/new', type: :view do
  before(:each) do
    @student_user_type = FactoryGirl.build(:student_user_type)
  end

  it 'renders edit student_user_type form' do
    render
    assert_select 'form[action=?][method=?]', student_user_types_path, 'post' do
      assert_select 'input#student_user_type_name[name=?]', 'student_user_type[name]'
      assert_select 'textarea#student_user_type_description[name=?]', 'student_user_type[description]'
      assert_select 'input#student_user_type_subscription[name=?]', 'student_user_type[subscription]'
      assert_select 'input#student_user_type_product_order[name=?]', 'student_user_type[product_order]'
    end
  end
end
