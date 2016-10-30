require 'rails_helper'

RSpec.describe 'mock_exams/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_course = FactoryGirl.create(:subject_course)
    @product = FactoryGirl.create(:product)
    temp_mock_exams = FactoryGirl.create_list(:mock_exam, 2, subject_course_id: @subject_course.id, product_id: @product.id)
    @mock_exams = MockExam.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of mock_exams' do
    render
    expect(rendered).to match(/#{@mock_exams.first.subject_course.name.to_s}/)
    expect(rendered).to match(/#{@mock_exams.first.product.name.to_s}/)
    expect(rendered).to match(/#{@mock_exams.first.name.to_s}/)
    expect(rendered).to match(/#{@mock_exams.first.sorting_order.to_s}/)
  end
end
