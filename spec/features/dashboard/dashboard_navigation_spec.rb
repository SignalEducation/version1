require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/subscription_plans_setup'


describe 'User navigating through the dashboard:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup'


  let!(:static_page) { FactoryGirl.create(:landing_page) }

  before(:each) do
    activate_authlogic
  end

  describe 'navigates to first cmes' do

    scenario 'not logged-in user', js: true  do
      visit root_path
      click_link 'Browse Courses'
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
      #expect(page).to have_content quiz_content_1.text_content
      click_link course_module_element_1_2.name
      within('#navbar') do
        click_link '#navbar-logo'
        click_link 'Browse Courses'
        click_link 'Dashboard'
      end
      #expect(page).to have_content exam_section_1.name
      #expect(page).to have_css('.progress')
      #expect(page).to have_css('.panel')
      #click_link 'Continue'
      #expect(page).to have_content course_module_element_1_3.name
      #expect(page).to have_content course_module_element_1_3.description
      #expect(page).to have_content I18n.t('views.courses.content_denied.not_logged_in.h2')
    end

    scenario 'when logged in as an individual user', js: true do
      visit root_path
      click_link 'Sign Up'
      expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
      student_sign_up_as('Dan', 'Murphy', nil, 'valid', eur, ireland, 1, true)
      within('#navbar') do
        click_link 'Dashboard'
      end
      expect(page).to have_content I18n.t('views.dashboard.individual_student.no_content_right_now')
      within('#navbar') do
        click_link 'Library'
      end
      expect(page).to have_content maybe_upcase institution_1.short_name
      expect(page).to have_content institution_1.description
      click_link institution_1.short_name
      expect(page).to have_content exam_section_1.name
      click_link 'Start'
      expect(page).to have_content course_module_element_1_1.name
      page.all('.quiz-answer-clickable').first.click
      expect(page).to have_content I18n.t('views.courses.show_results.h1')
      within('#navbar') do
        click_link '#navbar-logo'
      end
      expect(page).to have_content exam_section_1.name
      expect(page).to have_css('.progress')
      within('.progress-bar'){ expect(page).to have_content('1 / 3') }
      expect(page).to have_css('.panel')
      click_link 'Continue'
      expect(page).to have_content course_module_element_1_2.name
      within('#navbar') do
        click_link '#navbar-logo'
      end
      expect(page).to have_content exam_section_1.name
      expect(page).to have_css('.progress')
      #within('.progress-bar'){ expect(page).to have_content('2 / 3') }
      expect(page).to have_css('.panel')
      click_link 'Continue'
      expect(page).to have_content course_module_element_1_2.name
      sign_out
    end

  end

end
