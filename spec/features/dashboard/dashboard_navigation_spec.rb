require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'User navigating through the dashboard:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:static_page) { FactoryGirl.create(:landing_page) }

  before(:each) do
    activate_authlogic
  end

  describe 'User navigates to cmes' do

    scenario 'not logged-in user', js: true  do
      visit root_path
      click_link 'Dashboard'
      expect(page).to have_content I18n.t('views.dashboard.individual_student.no_content_right_now')
      within('#navbar') do
        click_link 'Library'
      end
      expect(page).to have_content maybe_upcase institution_1.short_name
      expect(page).to have_content institution_1.description
      click_link institution_1.short_name
      click_link 'Start'
      expect(page).to have_content course_module_1.name
      expect(page).to have_content course_module_element_1_1.name
      expect(page).to have_content course_module_element_1_2.name
      expect(page).to have_content course_module_element_1_3.name
      expect(page).to have_content quiz_content_1.text_content
      binding.pry
      click_link ''
    end

    scenario 'when logged in as one of the users', js: true do
      user_list.each do |this_user|
        sign_in_via_sign_in_page(this_user)
        within('#navbar') do
          click_link 'Library'
        end
        expect(page).to have_content maybe_upcase institution_1.short_name


      end
    end

  end


end