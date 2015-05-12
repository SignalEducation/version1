require 'rails_helper'

RSpec.describe 'marketing_categories/show', type: :view do
  before(:each) do
    @marketing_category = FactoryGirl.create(:marketing_category)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@marketing_category.name}/)
  end
end
