require 'rails_helper'

RSpec.describe 'corporate_groups/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_corporate_groups = FactoryGirl.create_list(:corporate_group, 2)
    @corporate_groups = CorporateGroup.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of corporate_groups' do
    render
  end
end
