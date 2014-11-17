require 'rails_helper'

RSpec.describe 'corporate_customers/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    # todo @country = FactoryGirl.create(:country)
    @owner = FactoryGirl.create(:corporate_customer_user)
    temp_corporate_customers = FactoryGirl.create_list(:corporate_customer, 2, owner_id: @owner.id) # todo , country_id: @country.id)
    @corporate_customers = CorporateCustomer.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of corporate_customers' do
    render
    expect(rendered).to match(/#{@corporate_customers.first.organisation_name.to_s}/)
    # todo expect(rendered).to match(/#{@corporate_customers.first.country.name.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@corporate_customers.first.owner.full_name.to_s}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
