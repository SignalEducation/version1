require 'rails_helper'

RSpec.describe 'marketing_categories/index', type: :view do
  before(:each) do
    temp_marketing_categories = FactoryGirl.create_list(:marketing_category, 2)
    @marketing_categories = MarketingCategory.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of marketing_categories' do
    render
    expect(rendered).to match(/#{@marketing_categories.first.name.to_s}/)
  end
end
