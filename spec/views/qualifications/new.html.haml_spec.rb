require 'rails_helper'

RSpec.describe 'qualifications/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:institution)
    @institutions = Institution.all
    @qualification = FactoryGirl.build(:qualification)
  end

  it 'renders edit qualification form' do
    render
    assert_select 'form[action=?][method=?]', qualifications_path, 'post' do
      assert_select 'select#qualification_institution_id[name=?]', 'qualification[institution_id]'
      assert_select 'input#qualification_name[name=?]', 'qualification[name]'
      assert_select 'input#qualification_name_url[name=?]', 'qualification[name_url]'
      assert_select 'input#qualification_sorting_order[name=?]', 'qualification[sorting_order]'
      assert_select 'input#qualification_active[name=?]', 'qualification[active]'
      assert_select 'input#qualification_cpd_hours_required_per_year[name=?]', 'qualification[cpd_hours_required_per_year]'
    end
  end
end
