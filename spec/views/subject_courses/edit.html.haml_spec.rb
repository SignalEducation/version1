require 'rails_helper'

RSpec.describe 'subject_courses/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:tutor)
    @tutors = Tutor.all
    @subject_course = FactoryGirl.create(:subject_course)
  end

  it 'renders new subject_course form' do
    render
    assert_select 'form[action=?][method=?]', subject_course_path(id: @subject_course.id), 'post' do
      assert_select 'input#subject_course_name[name=?]', 'subject_course[name]'
      assert_select 'input#subject_course_name_url[name=?]', 'subject_course[name_url]'
      assert_select 'input#subject_course_sorting_order[name=?]', 'subject_course[sorting_order]'
      assert_select 'input#subject_course_active[name=?]', 'subject_course[active]'
      assert_select 'input#subject_course_live[name=?]', 'subject_course[live]'
      assert_select 'input#subject_course_wistia_guid[name=?]', 'subject_course[wistia_guid]'
      assert_select 'select#subject_course_tutor_id[name=?]', 'subject_course[tutor_id]'
      assert_select 'input#subject_course_cme_count[name=?]', 'subject_course[cme_count]'
      assert_select 'input#subject_course_video_count[name=?]', 'subject_course[video_count]'
      assert_select 'input#subject_course_quiz_count[name=?]', 'subject_course[quiz_count]'
      assert_select 'input#subject_course_question_count[name=?]', 'subject_course[question_count]'
      assert_select 'textarea#subject_course_description[name=?]', 'subject_course[description]'
      assert_select 'input#subject_course_short_description[name=?]', 'subject_course[short_description]'
      assert_select 'input#subject_course_mailchimp_guid[name=?]', 'subject_course[mailchimp_guid]'
      assert_select 'input#subject_course_forum_url[name=?]', 'subject_course[forum_url]'
    end
  end
end
