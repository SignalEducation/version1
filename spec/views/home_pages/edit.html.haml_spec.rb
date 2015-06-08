require 'rails_helper'

RSpec.describe 'home_pages/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:subscription_plan_category)
    @subscription_plan_categories = SubscriptionPlanCategory.all
    @home_page = FactoryGirl.create(:home_page)
  end

  it 'renders new home_page form' do
    render
    assert_select 'form[action=?][method=?]', home_page_path(id: @home_page.id), 'post' do
      assert_select 'input#home_page_seo_title[name=?]', 'home_page[seo_title]'
      assert_select 'input#home_page_seo_description[name=?]', 'home_page[seo_description]'
      assert_select 'select#home_page_subscription_plan_category_id[name=?]', 'home_page[subscription_plan_category_id]'
      assert_select 'input#home_page_public_url[name=?]', 'home_page[public_url]'
    end
  end
end
