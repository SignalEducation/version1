require 'rails_helper'

RSpec.describe 'marketing_categories/new', type: :view do
  before(:each) do
    @marketing_category = FactoryGirl.build(:marketing_category)
  end

  it 'renders edit marketing_category form' do
    render
    assert_select 'form[action=?][method=?]', marketing_categories_path, 'post' do
      assert_select 'input#marketing_category_name[name=?]', 'marketing_category[name]'
    end
  end
end
