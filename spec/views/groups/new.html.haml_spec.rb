require 'rails_helper'

RSpec.describe 'groups/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:subject)
    @subjects = Subject.all
    @group = FactoryGirl.build(:group)
  end

  it 'renders edit group form' do
    render
    assert_select 'form[action=?][method=?]', groups_path, 'post' do
      assert_select 'input#group_name[name=?]', 'group[name]'
      assert_select 'input#group_name_url[name=?]', 'group[name_url]'
      assert_select 'input#group_active[name=?]', 'group[active]'
      assert_select 'input#group_sorting_order[name=?]', 'group[sorting_order]'
      assert_select 'textarea#group_description[name=?]', 'group[description]'
      assert_select 'select#group_subject_id[name=?]', 'group[subject_id]'
    end
  end
end
