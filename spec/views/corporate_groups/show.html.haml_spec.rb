require 'rails_helper'

RSpec.describe 'corporate_groups/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @corporate_group = FactoryGirl.create(:corporate_group)
  end

  it 'renders attributes' do
    render
  end
end
