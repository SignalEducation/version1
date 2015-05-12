require 'rails_helper'

RSpec.describe 'marketing_tokens/new', type: :view do
  before(:each) do
    @marketing_token = FactoryGirl.build(:marketing_token)
    @marketing_categories = MarketingCategory.all_in_order
  end

  it 'renders edit marketing_token form' do
    render
    assert_select 'form[action=?][method=?]', marketing_tokens_path, 'post' do
      assert_select 'input#marketing_token_code[name=?]', 'marketing_token[code]'
      assert_select 'input#marketing_token_is_hard[name=?]', 'marketing_token[is_hard]'
    end
  end
end
