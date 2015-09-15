require 'rails_helper'

RSpec.describe 'subject_courses/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @tutor = FactoryGirl.create(:tutor)
    temp_subject_courses = FactoryGirl.create_list(:subject_course, 2, tutor_id: @tutor.id)
    @subject_courses = SubjectCourse.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of subject_courses' do
    render
    expect(rendered).to match(/#{@subject_courses.first.name.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.name_url.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.sorting_order.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@subject_courses.first.wistia_guid.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.tutor.name.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.cme_count.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.video_count.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.quiz_count.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.question_count.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.description.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.short_description.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.mailchimp_guid.to_s}/)
    expect(rendered).to match(/#{@subject_courses.first.forum_url.to_s}/)
  end
end
