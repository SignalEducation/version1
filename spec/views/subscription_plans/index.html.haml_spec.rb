require 'rails_helper'

RSpec.describe 'subscription_plans/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @currency = FactoryGirl.create(:currency)
    temp_subscription_plans = FactoryGirl.create_list(:subscription_plan, 2, currency_id: @currency.id)
    @subscription_plans = SubscriptionPlan.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of subscription_plans' do
    render
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@subscription_plans.first.payment_frequency_in_months.to_s}/)
    expect(rendered).to match(/#{@subscription_plans.first.currency.name.to_s}/)
    expect(rendered).to match(/#{number_in_local_currency(@subscription_plans.first.price, @subscription_plans.first.currency_id)}/)
    expect(rendered).to match(/#{@subscription_plans.first.available_from.to_s(:short)}/)
    expect(rendered).to match(/#{@subscription_plans.first.available_to.to_s(:short)}/)
    expect(rendered).to match(/#{@subscription_plans.first.stripe_guid.to_s}/)
    expect(rendered).to match(/#{@subscription_plans.first.trial_period_in_days.to_s}/)
  end
end
