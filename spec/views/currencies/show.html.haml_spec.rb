require 'rails_helper'

RSpec.describe 'currencies/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @currency = FactoryGirl.create(:currency)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@currency.iso_code}/)
    expect(rendered).to match(/#{@currency.name}/)
    expect(rendered).to match(/#{@currency.leading_symbol}/)
    expect(rendered).to match(/#{@currency.trailing_symbol}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
