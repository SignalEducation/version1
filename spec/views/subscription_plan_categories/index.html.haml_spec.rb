require 'rails_helper'

RSpec.describe 'subscription_plan_categories/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_subscription_plan_categories = FactoryGirl.create_list(:subscription_plan_category, 2)
    @subscription_plan_categories = SubscriptionPlanCategory.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of subscription_plan_categories' do
    render
    expect(rendered).to match(/#{@subscription_plan_categories.first.name.to_s}/)
    expect(rendered).to match(/#{@subscription_plan_categories.first.available_from.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@subscription_plan_categories.first.available_to.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@subscription_plan_categories.first.guid.to_s}/)
  end
end
