require 'rails_helper'

RSpec.describe 'exam_sections/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:exam_level)
    @exam_levels = ExamLevel.all
    @exam_section = FactoryGirl.create(:exam_section)
  end

  it 'renders new exam_section form' do
    render
    assert_select 'form[action=?][method=?]', exam_section_path(id: @exam_section.id), 'post' do
      assert_select 'input#exam_section_name[name=?]', 'exam_section[name]'
      assert_select 'input#exam_section_name_url[name=?]', 'exam_section[name_url]'
      assert_select 'select#exam_section_exam_level_id[name=?]', 'exam_section[exam_level_id]'
      assert_select 'input#exam_section_active[name=?]', 'exam_section[active]'
      assert_select 'input#exam_section_sorting_order[name=?]', 'exam_section[sorting_order]'
      assert_select 'input#exam_section_best_possible_first_attempt_score[name=?]', 'exam_section[best_possible_first_attempt_score]'
    end
  end
end
