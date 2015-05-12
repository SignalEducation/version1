require 'rails_helper'

RSpec.describe 'marketing_tokens/edit', type: :view do
  before(:each) do
    @marketing_category = FactoryGirl.create(:marketing_category)
    @marketing_token = FactoryGirl.create(:marketing_token)
    @marketing_categories = MarketingCategory.all_in_order
  end

  it 'renders new marketing_token form' do
    render
    assert_select 'form[action=?][method=?]', marketing_token_path(id: @marketing_token.id), 'post' do
      assert_select 'input#marketing_token_code[name=?]', 'marketing_token[code]'
      assert_select 'select#marketing_token_marketing_category_id[name=?]', 'marketing_token[marketing_category_id]'
      assert_select 'input#marketing_token_is_hard[name=?]', 'marketing_token[is_hard]'
    end
  end
end
