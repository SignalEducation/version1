require 'rails_helper'

RSpec.describe 'white_paper_requests/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @white_paper = FactoryGirl.create(:white_paper)
    @white_paper_request = FactoryGirl.create(:white_paper_request, white_paper_id: @white_paper.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@white_paper_request.name}/)
    expect(rendered).to match(/#{@white_paper_request.email}/)
    expect(rendered).to match(/#{@white_paper_request.number}/)
    expect(rendered).to match(/#{@white_paper_request.web_url}/)
    expect(rendered).to match(/#{@white_paper_request.company_name}/)
    expect(rendered).to match(/#{@white_paper_request.white_paper.name}/)
  end
end
