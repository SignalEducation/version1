require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'User navigating through the library:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:static_page) { FactoryGirl.create(:landing_page) }

  before(:each) do
    activate_authlogic
  end

  scenario 'user signs in then navigates down hierarchy to first cme', js: true  do
    visit root_path
    click_link 'Library'
    expect(page).to have_content maybe_upcase institution_1.short_name
    expect(page).to have_content institution_1.description
  end

end
