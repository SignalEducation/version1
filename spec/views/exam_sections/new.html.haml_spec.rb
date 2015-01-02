require 'rails_helper'

RSpec.describe 'exam_sections/new', type: :view do
  before(:each) do
    qualification = FactoryGirl.create(:qualification)
    level = FactoryGirl.create(:exam_level, qualification_id: qualification.id)
    @exam_levels = ExamLevel.all
    @exam_section = FactoryGirl.build(:exam_section)
  end

  it 'renders edit exam_section form' do
    render
    assert_select 'form[action=?][method=?]', exam_sections_path, 'post' do
      assert_select 'input#exam_section_name[name=?]', 'exam_section[name]'
      assert_select 'input#exam_section_name_url[name=?]', 'exam_section[name_url]'
      assert_select 'select#exam_section_exam_level_id[name=?]', 'exam_section[exam_level_id]'
      assert_select 'input#exam_section_active[name=?]', 'exam_section[active]'
      assert_select 'input#exam_section_sorting_order[name=?]', 'exam_section[sorting_order]'
    end
  end
end
