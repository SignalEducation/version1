require 'rails_helper'

RSpec.describe 'tutor_applications/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @tutor_application = FactoryGirl.create(:tutor_application)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@tutor_application.first_name}/)
    expect(rendered).to match(/#{@tutor_application.last_name}/)
    expect(rendered).to match(/#{@tutor_application.email}/)
    expect(rendered).to match(/#{@tutor_application.info}/)
    expect(rendered).to match(/#{@tutor_application.description}/)
  end
end
