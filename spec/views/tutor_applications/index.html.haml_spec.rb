require 'rails_helper'

RSpec.describe 'tutor_applications/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_tutor_applications = FactoryGirl.create_list(:tutor_application, 2)
    @tutor_applications = TutorApplication.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of tutor_applications' do
    render
    expect(rendered).to match(/#{@tutor_applications.first.first_name.to_s}/)
    expect(rendered).to match(/#{@tutor_applications.first.last_name.to_s}/)
    expect(rendered).to match(/#{@tutor_applications.first.email.to_s}/)
    expect(rendered).to match(/#{@tutor_applications.first.info.to_s}/)
    expect(rendered).to match(/#{@tutor_applications.first.description.to_s}/)
  end
end
