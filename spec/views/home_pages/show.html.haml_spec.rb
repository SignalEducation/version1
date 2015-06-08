require 'rails_helper'

RSpec.describe 'home_pages/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subscription_plan_category = FactoryGirl.create(:subscription_plan_category)
    @home_page = FactoryGirl.create(:home_page, subscription_plan_category_id: @subscription_plan_category.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@home_page.seo_title}/)
    expect(rendered).to match(/#{@home_page.seo_description}/)
    expect(rendered).to match(/#{@home_page.subscription_plan_category.name}/)
    expect(rendered).to match(/#{@home_page.public_url}/)
  end
end
