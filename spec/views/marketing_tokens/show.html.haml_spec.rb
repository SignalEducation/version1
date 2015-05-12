require 'rails_helper'

RSpec.describe 'marketing_tokens/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @marketing_category = FactoryGirl.create(:marketing_category)
    @marketing_token = FactoryGirl.create(:marketing_token, marketing_category_id: @marketing_category.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@marketing_token.code}/)
    expect(rendered).to match(/#{@marketing_token.marketing_category.name}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
