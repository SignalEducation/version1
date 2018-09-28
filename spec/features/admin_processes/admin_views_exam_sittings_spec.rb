require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/system_setup'

feature 'An admin views exam sittings', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'system_setup'

  before(:each) do
    activate_authlogic
    a = admin_user

    sign_in_via_sign_in_page(admin_user)
    click_link 'Console'
    click_link 'Sittings + Enrolments'
  end

  scenario 'and sees the correct page heading' do
    expect(page).to have_content('Exam Sittings')
  end

  scenario 'and the filter logic is set to ACTIVE be default', js: true do
    expect(current_url).not_to match('sort_by')
    within '#sort_by' do
      expect(page).to have_content 'active'
    end
  end

  scenario 'and can filter by NOT-ACTIVE', js: true do
    select "not-active", from: "sort_by"

    expect(current_url).to match('sort_by=not-active')
    # expect not to see any active sittings
  end

  scenario 'and can filter by ALL', js: true do
    select "all", from: "sort_by"

    expect(current_url).to match('sort_by=all')
    # expect to see both active and not-active sittings
  end

  scenario 'and can filter by ACTIVE again after selecting another sort_by', js: true do
    select 'all', from: 'sort_by'
    select 'active', from: 'sort_by'

    expect(current_url).to match('sort_by=active')
    # expect not to see any not-active sittings
  end
end