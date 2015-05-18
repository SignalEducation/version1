require 'rails_helper'

RSpec.describe 'tutor_applications/new', type: :view do
  before(:each) do
    @tutor_application = FactoryGirl.build(:tutor_application)
  end

  xit 'renders edit tutor_application form' do
    render
    assert_select 'form[action=?][method=?]', tutor_applications_path, 'post' do
      assert_select 'input#tutor_application_first_name[name=?]', 'tutor_application[first_name]'
      assert_select 'input#tutor_application_last_name[name=?]', 'tutor_application[last_name]'
      assert_select 'input#tutor_application_email[name=?]', 'tutor_application[email]'
      assert_select 'textarea#tutor_application_info[name=?]', 'tutor_application[info]'
      assert_select 'textarea#tutor_application_description[name=?]', 'tutor_application[description]'
    end
  end
end
