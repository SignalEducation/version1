require 'rails_helper'

RSpec.describe 'countries/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:currency)
    @currencies = Currency.all
    @country = FactoryGirl.build(:country, currency_id: @currencies.first.id)
  end

  it 'renders edit country form' do
    render
    assert_select 'form[action=?][method=?]', countries_path, 'post' do
      assert_select 'input#country_name[name=?]', 'country[name]'
      assert_select 'input#country_iso_code[name=?]', 'country[iso_code]'
      assert_select 'input#country_country_tld[name=?]', 'country[country_tld]'
      assert_select 'input#country_in_the_eu[name=?]', 'country[in_the_eu]'
      assert_select 'select#country_currency_id[name=?]', 'country[currency_id]'
    end
  end
end
