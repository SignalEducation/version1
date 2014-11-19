require 'rails_helper'

RSpec.describe 'vat_codes/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:country)
    @countries = Country.all
    @vat_code = FactoryGirl.build(:vat_code)
  end

  it 'renders edit vat_code form' do
    render
    assert_select 'form[action=?][method=?]', vat_codes_path, 'post' do
      assert_select 'select#vat_code_country_id[name=?]', 'vat_code[country_id]'
      assert_select 'input#vat_code_name[name=?]', 'vat_code[name]'
      assert_select 'input#vat_code_label[name=?]', 'vat_code[label]'
      assert_select 'input#vat_code_wiki_url[name=?]', 'vat_code[wiki_url]'
    end
  end
end
