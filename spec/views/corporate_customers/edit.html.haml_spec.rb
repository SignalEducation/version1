require 'rails_helper'

RSpec.describe 'corporate_customers/edit', type: :view do
  before(:each) do
    # todo x = FactoryGirl.create(:country)
    # todo @countries = Country.all
    x = FactoryGirl.create(:corporate_customer_user)
    @corporate_customer = FactoryGirl.create(:corporate_customer)
  end

  it 'renders new corporate_customer form' do
    render
    assert_select 'form[action=?][method=?]', corporate_customer_path(id: @corporate_customer.id), 'post' do
      assert_select 'input#corporate_customer_organisation_name[name=?]', 'corporate_customer[organisation_name]'
      assert_select 'textarea#corporate_customer_address[name=?]', 'corporate_customer[address]'
      # todo assert_select 'select#corporate_customer_country_id[name=?]', 'corporate_customer[country_id]'
      assert_select 'input#corporate_customer_payments_by_card[name=?]', 'corporate_customer[payments_by_card]'
      assert_select 'input#corporate_customer_stripe_customer_guid[name=?]', 'corporate_customer[stripe_customer_guid]'
    end
  end
end
