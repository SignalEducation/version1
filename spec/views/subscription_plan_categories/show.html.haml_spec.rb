require 'rails_helper'

RSpec.describe 'subscription_plan_categories/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subscription_plan_category = FactoryGirl.create(:subscription_plan_category)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@subscription_plan_category.name}/)
    expect(rendered).to match(/#{@subscription_plan_category.available_from.to_s(:standard)}/)
    expect(rendered).to match(/#{@subscription_plan_category.available_to.to_s(:standard)}/)
    expect(rendered).to match(/#{@subscription_plan_category.guid}/)
  end
end
