require 'rails_helper'

RSpec.describe 'home_pages/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subscription_plan_category = FactoryGirl.create(:subscription_plan_category)
    temp_home_pages = FactoryGirl.create_list(:home_page, 2, subscription_plan_category_id: @subscription_plan_category.id)
    @home_pages = HomePage.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of home_pages' do
    render
    expect(rendered).to match(/#{@home_pages.first.seo_title.to_s}/)
    expect(rendered).to match(/#{@home_pages.first.seo_description.to_s}/)
    expect(rendered).to match(/#{@home_pages.first.subscription_plan_category.name.to_s}/)
    expect(rendered).to match(/#{@home_pages.first.public_url.to_s}/)
  end
end
