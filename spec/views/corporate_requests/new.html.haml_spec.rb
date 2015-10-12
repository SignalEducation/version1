require 'rails_helper'

RSpec.describe 'corporate_requests/new', type: :view do
  before(:each) do
    @corporate_request = FactoryGirl.build(:corporate_request)
  end

  it 'renders edit corporate_request form' do
    render
    assert_select 'form[action=?][method=?]', corporate_requests_path, 'post' do
      assert_select 'input#corporate_request_name[name=?]', 'corporate_request[name]'
      assert_select 'input#corporate_request_title[name=?]', 'corporate_request[title]'
      assert_select 'input#corporate_request_company[name=?]', 'corporate_request[company]'
      assert_select 'input#corporate_request_email[name=?]', 'corporate_request[email]'
      assert_select 'input#corporate_request_phone_number[name=?]', 'corporate_request[phone_number]'
      assert_select 'input#corporate_request_website[name=?]', 'corporate_request[website]'
      assert_select 'textarea#corporate_request_personal_message[name=?]', 'corporate_request[personal_message]'
    end
  end
end
