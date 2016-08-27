require 'rails_helper'

RSpec.describe 'subject_course_categories/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_course_category = FactoryGirl.create(:subject_course_category)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@subject_course_category.name}/)
    expect(rendered).to match(/#{@subject_course_category.payment_type}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@subject_course_category.subdomain}/)
  end
end
