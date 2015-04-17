require 'rails_helper'

RSpec.describe 'institutions/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:subject_area)
    @subject_areas = SubjectArea.all
    @institution = FactoryGirl.build(:institution)
  end

  xit 'renders edit institution form' do
    render
    assert_select 'form[action=?][method=?]', institutions_path, 'post' do
      assert_select 'input#institution_name[name=?]', 'institution[name]'
      assert_select 'input#institution_short_name[name=?]', 'institution[short_name]'
      assert_select 'input#institution_name_url[name=?]', 'institution[name_url]'
      assert_select 'textarea#institution_description[name=?]', 'institution[description]'
      assert_select 'input#institution_feedback_url[name=?]', 'institution[feedback_url]'
      assert_select 'input#institution_help_desk_url[name=?]', 'institution[help_desk_url]'
      assert_select 'select#institution_subject_area_id[name=?]', 'institution[subject_area_id]'
      assert_select 'input#institution_sorting_order[name=?]', 'institution[sorting_order]'
      assert_select 'input#institution_active[name=?]', 'institution[active]'
    end
  end
end
