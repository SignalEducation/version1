require 'rails_helper'

RSpec.describe 'student_user_types/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_student_user_types = FactoryGirl.create_list(:student_user_type, 2)
    @student_user_types = StudentUserType.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of student_user_types' do
    render
    expect(rendered).to match(/#{@student_user_types.first.name.to_s}/)
    expect(rendered).to match(/#{@student_user_types.first.description.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
