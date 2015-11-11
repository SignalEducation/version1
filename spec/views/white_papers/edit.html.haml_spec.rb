require 'rails_helper'

RSpec.describe 'white_papers/edit', type: :view do
  before(:each) do
    @white_paper = FactoryGirl.create(:white_paper)
  end

  it 'renders new white_paper form' do
    render
    assert_select 'form[action=?][method=?]', white_paper_path(id: @white_paper.id), 'post' do
      assert_select 'input#white_paper_title[name=?]', 'white_paper[title]'
      assert_select 'textarea#white_paper_description[name=?]', 'white_paper[description]'
    end
  end
end
