require 'rails_helper'

RSpec.describe 'mock_exams/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @subject_course = FactoryGirl.create(:subject_course)
    @product = FactoryGirl.create(:product)
    @mock_exam = FactoryGirl.create(:mock_exam, subject_course_id: @subject_course.id, product_id: @product.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@mock_exam.subject_course.name}/)
    expect(rendered).to match(/#{@mock_exam.product.name}/)
    expect(rendered).to match(/#{@mock_exam.name}/)
    expect(rendered).to match(/#{@mock_exam.sorting_order}/)
  end
end
