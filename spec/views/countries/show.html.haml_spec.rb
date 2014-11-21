require 'rails_helper'

RSpec.describe 'countries/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @currency = FactoryGirl.create(:currency)
    @country = FactoryGirl.create(:country, currency_id: @currency.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@country.name}/)
    expect(rendered).to match(/#{@country.iso_code}/)
    expect(rendered).to match(/#{@country.country_tld}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@country.currency.name}/)
  end
end
