require 'rails_helper'

RSpec.describe 'subject_course_categories/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_subject_course_categories = FactoryGirl.create_list(:subject_course_category, 2)
    @subject_course_categories = SubjectCourseCategory.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of subject_course_categories' do
    render
    expect(rendered).to match(/#{@subject_course_categories.first.name.to_s}/)
    expect(rendered).to match(/#{@subject_course_categories.first.payment_type.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@subject_course_categories.first.subdomain.to_s}/)
  end
end
