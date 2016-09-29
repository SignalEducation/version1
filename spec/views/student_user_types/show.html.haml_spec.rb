require 'rails_helper'

RSpec.describe 'student_user_types/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @student_user_type = FactoryGirl.create(:student_user_type)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@student_user_type.name}/)
    expect(rendered).to match(/#{@student_user_type.description}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
