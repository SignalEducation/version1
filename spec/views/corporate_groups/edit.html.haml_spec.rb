require 'rails_helper'

RSpec.describe 'corporate_groups/edit', type: :view do
  before(:each) do
    @corporate_group = FactoryGirl.create(:corporate_group)
  end

  it 'renders new corporate_group form' do
    render
    assert_select 'form[action=?][method=?]', corporate_group_path(id: @corporate_group.id), 'post' do
    end
  end
end
