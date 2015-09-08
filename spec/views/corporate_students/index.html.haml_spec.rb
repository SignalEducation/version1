require 'rails_helper'

RSpec.describe 'corporate_students/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_corporate_students = FactoryGirl.create_list(:corporate_student, 2)
    @corporate_students = CorporateStudent.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of corporate_students' do
    render
    expect(rendered).to match(/#{@corporate_students.first.index.to_s}/)
    expect(rendered).to match(/#{@corporate_students.first.new.to_s}/)
    expect(rendered).to match(/#{@corporate_students.first.create.to_s}/)
  end
end
