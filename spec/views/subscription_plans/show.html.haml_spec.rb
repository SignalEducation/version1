require 'rails_helper'

RSpec.describe 'subscription_plans/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @currency = FactoryGirl.create(:currency)
    @subscription_plan = FactoryGirl.create(:subscription_plan, currency_id: @currency.id)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@subscription_plan.payment_frequency_in_months}/)
    expect(rendered).to match(/#{@subscription_plan.currency.name}/)
    expect(rendered).to match(/#{@subscription_plan.price}/)
    expect(rendered).to match(/#{@subscription_plan.available_from}/)
    expect(rendered).to match(/#{@subscription_plan.available_to}/)
    expect(rendered).to match(/#{@subscription_plan.stripe_guid}/)
    expect(rendered).to match(/#{@subscription_plan.trial_period_in_days}/)
  end
end
