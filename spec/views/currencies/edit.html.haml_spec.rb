require 'rails_helper'

RSpec.describe 'currencies/edit', type: :view do
  before(:each) do
    @currency = FactoryGirl.create(:currency)
  end

  it 'renders new currency form' do
    render
    assert_select 'form[action=?][method=?]', currency_path(id: @currency.id), 'post' do
      assert_select 'input#currency_iso_code[name=?]', 'currency[iso_code]'
      assert_select 'input#currency_name[name=?]', 'currency[name]'
      assert_select 'input#currency_leading_symbol[name=?]', 'currency[leading_symbol]'
      assert_select 'input#currency_trailing_symbol[name=?]', 'currency[trailing_symbol]'
      assert_select 'input#currency_active[name=?]', 'currency[active]'
      assert_select 'input#currency_sorting_order[name=?]', 'currency[sorting_order]'
    end
  end
end
