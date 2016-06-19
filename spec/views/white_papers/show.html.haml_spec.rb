require 'rails_helper'

RSpec.describe 'white_papers/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @white_paper = FactoryGirl.create(:white_paper)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@white_paper.title}/)
    expect(rendered).to match(/#{@white_paper.description}/)
  end
end
