require 'rails_helper'

RSpec.describe 'vat_codes/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @country = FactoryGirl.create(:country)
    temp_vat_codes = FactoryGirl.create_list(:vat_code, 2, country_id: @country.id)
    @vat_codes = VatCode.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of vat_codes' do
    render
    expect(rendered).to match(/#{@vat_codes.first.country.name.to_s}/)
    expect(rendered).to match(/#{@vat_codes.first.name.to_s}/)
    expect(rendered).to match(/#{@vat_codes.first.label.to_s}/)
    expect(rendered).to match(/#{@vat_codes.first.wiki_url.to_s}/)
  end
end
