require 'rails_helper'

RSpec.describe 'marketing_tokens/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @marketing_category = FactoryGirl.create(:marketing_category)
    temp_marketing_tokens = FactoryGirl.create_list(:marketing_token, 2, marketing_category_id: @marketing_category.id)
    @marketing_tokens = MarketingToken.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of marketing_tokens' do
    render
    expect(rendered).to match(/#{@marketing_tokens.first.code.to_s}/)
    expect(rendered).to match(/#{@marketing_tokens.first.marketing_category.name.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
