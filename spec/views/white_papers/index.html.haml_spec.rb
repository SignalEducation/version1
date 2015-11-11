require 'rails_helper'

RSpec.describe 'white_papers/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_white_papers = FactoryGirl.create_list(:white_paper, 2)
    @white_papers = WhitePaper.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of white_papers' do
    render
    expect(rendered).to match(/#{@white_papers.first.title.to_s}/)
    expect(rendered).to match(/#{@white_papers.first.description.to_s}/)
  end
end
