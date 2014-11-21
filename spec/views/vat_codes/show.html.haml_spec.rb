require 'rails_helper'

RSpec.describe 'vat_codes/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @country = FactoryGirl.create(:country)
    @vat_code = FactoryGirl.create(:vat_code, country_id: @country.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@vat_code.country.name}/)
    expect(rendered).to match(/#{@vat_code.name}/)
    expect(rendered).to match(/#{@vat_code.label}/)
    expect(rendered).to match(/#{@vat_code.wiki_url}/)
  end
end
