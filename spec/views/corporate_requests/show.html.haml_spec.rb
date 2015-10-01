require 'rails_helper'

RSpec.describe 'corporate_requests/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @corporate_request = FactoryGirl.create(:corporate_request)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@corporate_request.name}/)
    expect(rendered).to match(/#{@corporate_request.title}/)
    expect(rendered).to match(/#{@corporate_request.company}/)
    expect(rendered).to match(/#{@corporate_request.email}/)
    expect(rendered).to match(/#{@corporate_request.phone_number}/)
    expect(rendered).to match(/#{@corporate_request.website}/)
    expect(rendered).to match(/#{@corporate_request.message}/)
  end
end
