require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'
require 'support/course_content'


describe 'User navigating through the library:', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'
  include_context 'course_content'


  before(:each) do
    activate_authlogic
  end

  describe 'User navigates down hierarchy to first cme' do

    scenario 'not logged-in user', js: true  do
      visit root_path
      visit home_path
      click_on('Courses')
      click_link(group_1.name)
      click_link(subject_course_1.name)
      expect(page).to have_content subject_course_1.name
    end

    scenario 'when logged in as one of the users', js: true do
      user_list.each do |this_user|
        sign_in_via_sign_in_page(this_user)

        within('.navbar.navbar-default') do
          click_link 'Courses'
        end
        click_link(group_1.name)
        click_link(subject_course_1.name)
        expect(page).to have_content course_module_1.name
        expect(page).to have_content subject_course_1.name

        parent = page.find('.course-topics-list li:first-child')
        parent.click

        expect(page).to have_content course_module_element_1_1.name

        sign_out
        print '>'
      end
    end

  end

end
