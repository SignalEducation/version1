require 'rails_helper'

RSpec.describe 'corporate_groups/new', type: :view do
  before(:each) do
    @corporate_group = FactoryGirl.build(:corporate_group)
  end

  it 'renders edit corporate_group form' do
    render
    assert_select 'form[action=?][method=?]', corporate_groups_path, 'post' do
    end
  end
end
