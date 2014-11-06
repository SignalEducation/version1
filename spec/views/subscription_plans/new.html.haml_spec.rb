require 'rails_helper'

RSpec.describe 'subscription_plans/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:currency)
    @currencies = Currency.all
    @subscription_plan = FactoryGirl.build(:subscription_plan)
  end

  it 'renders edit subscription_plan form' do
    render
    assert_select 'form[action=?][method=?]', subscription_plans_path, 'post' do
      assert_select 'input#subscription_plan_available_to_students[name=?]', 'subscription_plan[available_to_students]'
      assert_select 'input#subscription_plan_available_to_corporates[name=?]', 'subscription_plan[available_to_corporates]'
      assert_select 'input#subscription_plan_all_you_can_eat[name=?]', 'subscription_plan[all_you_can_eat]'
      assert_select 'input#subscription_plan_payment_frequency_in_months[name=?]', 'subscription_plan[payment_frequency_in_months]'
      assert_select 'select#subscription_plan_currency_id[name=?]', 'subscription_plan[currency_id]'
      assert_select 'input#subscription_plan_price[name=?]', 'subscription_plan[price]'
      assert_select 'input#subscription_plan_available_from[name=?]', 'subscription_plan[available_from]'
      assert_select 'input#subscription_plan_available_to[name=?]', 'subscription_plan[available_to]'
      assert_select 'input#subscription_plan_stripe_guid[name=?]', 'subscription_plan[stripe_guid]'
      assert_select 'input#subscription_plan_trial_period_in_days[name=?]', 'subscription_plan[trial_period_in_days]'
    end
  end
end
