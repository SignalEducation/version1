require 'rails_helper'

RSpec.describe 'corporate_customers/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    # todo @country = FactoryGirl.create(:country)
    @corporate_customer = FactoryGirl.create(:corporate_customer) # todo , country_id: @country.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@corporate_customer.organisation_name}/)
    expect(rendered).to match(/#{@corporate_customer.address}/)
    # todo expect(rendered).to match(/#{@corporate_customer.country.name}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@corporate_customer.stripe_customer_guid}/)
    expect(rendered).to match(/nice_boolean/)
  end
end
