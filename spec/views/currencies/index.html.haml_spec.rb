require 'rails_helper'

RSpec.describe 'currencies/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_currencies = FactoryGirl.create_list(:currency, 2)
    @currencies = Currency.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of currencies' do
    render
    expect(rendered).to match(/#{@currencies.first.iso_code.to_s}/)
    expect(rendered).to match(/#{@currencies.first.name.to_s}/)
    expect(rendered).to match(/#{@currencies.first.leading_symbol.to_s}/)
    expect(rendered).to match(/#{@currencies.first.trailing_symbol.to_s}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
