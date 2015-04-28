require 'rails_helper'

RSpec.describe 'marketing_categories/edit', type: :view do
  before(:each) do
    @marketing_category = FactoryGirl.create(:marketing_category)
  end

  it 'renders new marketing_category form' do
    render
    assert_select 'form[action=?][method=?]', marketing_category_path(id: @marketing_category.id), 'post' do
      assert_select 'input#marketing_category_name[name=?]', 'marketing_category[name]'
    end
  end
end
