require 'rails_helper'

RSpec.describe 'countries/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @currency = FactoryGirl.create(:currency)
    temp_countries = FactoryGirl.create_list(:country, 2, currency_id: @currency.id)
    @countries = Country.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of countries' do
    render
    expect(rendered).to match(/#{@countries.first.name.to_s}/)
    expect(rendered).to match(/#{@countries.first.iso_code.to_s}/)
    expect(rendered).to match(/#{@countries.first.country_tld.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@countries.first.currency.name.to_s}/)
  end
end
