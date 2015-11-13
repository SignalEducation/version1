require 'rails_helper'

RSpec.describe 'white_paper_requests/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @white_paper = FactoryGirl.create(:white_paper)
    temp_white_paper_requests = FactoryGirl.create_list(:white_paper_request, 2, white_paper_id: @white_paper.id)
    @white_paper_requests = WhitePaperRequest.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of white_paper_requests' do
    render
    expect(rendered).to match(/#{@white_paper_requests.first.name.to_s}/)
    expect(rendered).to match(/#{@white_paper_requests.first.email.to_s}/)
    expect(rendered).to match(/#{@white_paper_requests.first.number.to_s}/)
    expect(rendered).to match(/#{@white_paper_requests.first.web_url.to_s}/)
    expect(rendered).to match(/#{@white_paper_requests.first.company_name.to_s}/)
    expect(rendered).to match(/#{@white_paper_requests.first.white_paper.name.to_s}/)
  end
end
