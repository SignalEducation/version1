require 'rails_helper'

RSpec.describe 'white_papers/new', type: :view do
  before(:each) do
    @white_paper = FactoryGirl.build(:white_paper)
  end

  it 'renders edit white_paper form' do
    render
    assert_select 'form[action=?][method=?]', white_papers_path, 'post' do
      assert_select 'input#white_paper_title[name=?]', 'white_paper[title]'
      assert_select 'textarea#white_paper_description[name=?]', 'white_paper[description]'
    end
  end
end
