require 'rails_helper'

RSpec.describe 'subscription_plan_categories/edit', type: :view do
  before(:each) do
    @subscription_plan_category = FactoryGirl.create(:subscription_plan_category)
  end

  xit 'renders new subscription_plan_category form' do
    render
    assert_select 'form[action=?][method=?]', subscription_plan_category_path(id: @subscription_plan_category.id), 'post' do
      assert_select 'input#subscription_plan_category_name[name=?]', 'subscription_plan_category[name]'
      assert_select 'input#subscription_plan_category_available_from[name=?]', 'subscription_plan_category[available_from]'
      assert_select 'input#subscription_plan_category_available_to[name=?]', 'subscription_plan_category[available_to]'
      assert_select 'input#subscription_plan_category_guid[name=?]', 'subscription_plan_category[guid]'
    end
  end
end
