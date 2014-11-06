require 'rails_helper'

RSpec.describe 'exam_levels/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:institution)
    @institutions = Institution.all
    x = FactoryGirl.create(:exam_level)
    @exam_levels = ExamLevel.all
    x = FactoryGirl.create(:exam_section)
    @exam_sections = ExamSection.all
    x = FactoryGirl.create(:tutor)
    @tutors = Tutor.all
    @course_module = FactoryGirl.build(:course_module)
  end

  xit 'renders edit exam_level form' do
    render
    assert_select 'form[action=?][method=?]', course_modules_path, 'post' do
      assert_select 'select#course_module_institution_id[name=?]', 'course_module[institution_id]'
      assert_select 'select#course_module_exam_level_id[name=?]', 'course_module[exam_level_id]'
      assert_select 'select#course_module_exam_section_id[name=?]', 'course_module[exam_section_id]'
      assert_select 'input#course_module_name[name=?]', 'course_module[name]'
      assert_select 'input#course_module_name_url[name=?]', 'course_module[name_url]'
      assert_select 'textarea#course_module_description[name=?]', 'course_module[description]'
      assert_select 'select#course_module_tutor_id[name=?]', 'course_module[tutor_id]'
      assert_select 'input#course_module_sorting_order[name=?]', 'course_module[sorting_order]'
      assert_select 'input#course_module_estimated_time_in_seconds[name=?]', 'course_module[estimated_time_in_seconds]'
      assert_select 'input#course_module_compulsory[name=?]', 'course_module[compulsory]'
      assert_select 'input#course_module_active[name=?]', 'course_module[active]'
    end
  end
end
