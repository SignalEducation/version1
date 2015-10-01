require 'rails_helper'

RSpec.describe 'corporate_requests/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_corporate_requests = FactoryGirl.create_list(:corporate_request, 2)
    @corporate_requests = CorporateRequest.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of corporate_requests' do
    render
    expect(rendered).to match(/#{@corporate_requests.first.name.to_s}/)
    expect(rendered).to match(/#{@corporate_requests.first.title.to_s}/)
    expect(rendered).to match(/#{@corporate_requests.first.company.to_s}/)
    expect(rendered).to match(/#{@corporate_requests.first.email.to_s}/)
    expect(rendered).to match(/#{@corporate_requests.first.phone_number.to_s}/)
    expect(rendered).to match(/#{@corporate_requests.first.website.to_s}/)
    expect(rendered).to match(/#{@corporate_requests.first.message.to_s}/)
  end
end
