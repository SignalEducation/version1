require 'rails_helper'

RSpec.describe 'subject_areas/new', type: :view do
  before(:each) do
    @subject_area = FactoryGirl.build(:subject_area)
  end

  xit 'renders edit subject_area form' do
    render
    assert_select 'form[action=?][method=?]', subject_areas_path, 'post' do
      assert_select 'input#subject_area_name[name=?]', 'subject_area[name]'
      assert_select 'input#subject_area_name_url[name=?]', 'subject_area[name_url]'
      assert_select 'input#subject_area_sorting_order[name=?]', 'subject_area[sorting_order]'
      assert_select 'input#subject_area_active[name=?]', 'subject_area[active]'
    end
  end
end
