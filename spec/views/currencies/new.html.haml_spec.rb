require 'rails_helper'

RSpec.describe 'currencies/new', type: :view do
  before(:each) do
    @currency = FactoryGirl.build(:currency)
  end

  it 'renders edit currency form' do
    render
    assert_select 'form[action=?][method=?]', currencies_path, 'post' do
      assert_select 'input#currency_iso_code[name=?]', 'currency[iso_code]'
      assert_select 'input#currency_name[name=?]', 'currency[name]'
      assert_select 'input#currency_leading_symbol[name=?]', 'currency[leading_symbol]'
      assert_select 'input#currency_trailing_symbol[name=?]', 'currency[trailing_symbol]'
      assert_select 'input#currency_active[name=?]', 'currency[active]'
      assert_select 'input#currency_sorting_order[name=?]', 'currency[sorting_order]'
    end
  end
end
