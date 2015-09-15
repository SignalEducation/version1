require 'rails_helper'

RSpec.describe 'subject_courses/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @tutor = FactoryGirl.create(:tutor)
    @subject_course = FactoryGirl.create(:subject_course, tutor_id: @tutor.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@subject_course.name}/)
    expect(rendered).to match(/#{@subject_course.name_url}/)
    expect(rendered).to match(/#{@subject_course.sorting_order}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@subject_course.wistia_guid}/)
    expect(rendered).to match(/#{@subject_course.tutor.name}/)
    expect(rendered).to match(/#{@subject_course.cme_count}/)
    expect(rendered).to match(/#{@subject_course.video_count}/)
    expect(rendered).to match(/#{@subject_course.quiz_count}/)
    expect(rendered).to match(/#{@subject_course.question_count}/)
    expect(rendered).to match(/#{@subject_course.description}/)
    expect(rendered).to match(/#{@subject_course.short_description}/)
    expect(rendered).to match(/#{@subject_course.mailchimp_guid}/)
    expect(rendered).to match(/#{@subject_course.forum_url}/)
  end
end
