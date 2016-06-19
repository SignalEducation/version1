require 'rails_helper'

RSpec.describe 'white_paper_requests/edit', type: :view do
  before(:each) do
    x = FactoryGirl.create(:white_paper)
    @white_papers = WhitePaper.all
    @white_paper_request = FactoryGirl.create(:white_paper_request)
  end

  it 'renders new white_paper_request form' do
    render
    assert_select 'form[action=?][method=?]', white_paper_request_path(id: @white_paper_request.id), 'post' do
      assert_select 'input#white_paper_request_name[name=?]', 'white_paper_request[name]'
      assert_select 'input#white_paper_request_email[name=?]', 'white_paper_request[email]'
      assert_select 'input#white_paper_request_number[name=?]', 'white_paper_request[number]'
      assert_select 'input#white_paper_request_web_url[name=?]', 'white_paper_request[web_url]'
      assert_select 'input#white_paper_request_company_name[name=?]', 'white_paper_request[company_name]'
      assert_select 'select#white_paper_request_white_paper_id[name=?]', 'white_paper_request[white_paper_id]'
    end
  end
end
