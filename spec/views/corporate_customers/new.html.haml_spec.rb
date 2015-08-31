require 'rails_helper'

RSpec.describe 'corporate_customers/new', type: :view do
  before(:each) do
    # todo x = FactoryGirl.create(:country)
    # todo @countries = Country.all
    x = FactoryGirl.create(:corporate_customer_user)
    @corporate_customer = FactoryGirl.build(:corporate_customer)
  end

  it 'renders edit corporate_customer form' do
    render
    assert_select 'form[action=?][method=?]', corporate_customers_path, 'post' do
      assert_select 'input#corporate_customer_organisation_name[name=?]', 'corporate_customer[organisation_name]'
      assert_select 'textarea#corporate_customer_address[name=?]', 'corporate_customer[address]'
      # todo assert_select 'select#corporate_customer_country_id[name=?]', 'corporate_customer[country_id]'
      assert_select 'input#corporate_customer_payments_by_card[name=?]', 'corporate_customer[payments_by_card]'
    end
  end
end
