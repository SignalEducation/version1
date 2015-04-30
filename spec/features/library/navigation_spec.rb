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

  describe 'User navigates down hierarchy to first cme' do

    scenario 'not logged-in user', js: true  do
      visit root_path
      click_link 'Library'
      expect(page).to have_content maybe_upcase institution_1.short_name
      expect(page).to have_content institution_1.description
      click_link institution_1.short_name
      click_link 'Start'
      expect(page).to have_content course_module_1.name
      expect(page).to have_content course_module_element_1_1.name
      expect(page).to have_content course_module_element_1_2.name
      expect(page).to have_content course_module_element_1_3.name
      expect(page).to have_content quiz_content_1.text_content
    end

    scenario 'when logged in as one of the users', js: true do
      user_list.each do |this_user|
        sign_in_via_sign_in_page(this_user)
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
        sign_out
        print '>'
      end
    end

  end

  describe 'User navigates up/down the library hierarchy' do

    scenario 'not logged-in user', js: true  do
      visit root_path
      click_link 'Library'
      expect(page).to have_content maybe_upcase institution_1.short_name
      expect(page).to have_content institution_1.description
      click_link institution_1.short_name
      expect(page).to have_content maybe_upcase exam_level_1.name
      expect(page).to have_content exam_section_1.name
      click_link exam_section_1.name
      expect(page).to have_content maybe_upcase exam_section_1.name
      expect(page).to have_content course_module_1.name
      expect(page).to have_css('.progress-bar')
      click_link course_module_1.name
      expect(page).to have_content course_module_1.name
      expect(page).to have_content course_module_element_1_2.name
      expect(page).to have_content quiz_content_1.text_content
      click_link '#library-btn'
      expect(page).to have_content maybe_upcase exam_section_1.name
      expect(page).to have_content course_module_1.name
      click_link '#back-btn'
      #The back btn skips a exam_section_1 show should the library show do this as well ?
      #expect(page).to have_content maybe_upcase exam_level_1.name
      #expect(page).to have_content exam_section_1.name
      expect(page).to have_content maybe_upcase institution_1.short_name
      expect(page).to have_content institution_1.description
    end

    scenario 'when logged in as one of the users', js: true do
      user_list.each do |this_user|
        sign_in_via_sign_in_page(this_user)
        within('#navbar') do
          click_link 'Library'
        end
        expect(page).to have_content maybe_upcase institution_1.short_name
        expect(page).to have_content institution_1.description
        click_link institution_1.short_name
        expect(page).to have_content maybe_upcase exam_level_1.name
        expect(page).to have_content exam_section_1.name
        click_link exam_section_1.name
        expect(page).to have_content maybe_upcase exam_section_1.name
        expect(page).to have_content course_module_1.name
        expect(page).to have_css('.progress-bar')
        click_link course_module_1.name
        expect(page).to have_content course_module_1.name
        expect(page).to have_content course_module_element_1_2.name
        expect(page).to have_content quiz_content_1.text_content
        click_link '#library-btn'
        expect(page).to have_content maybe_upcase exam_section_1.name
        expect(page).to have_content course_module_1.name
        click_link '#back-btn'
        expect(page).to have_content maybe_upcase institution_1.short_name
        expect(page).to have_content institution_1.description
        click_link institution_1.short_name
        expect(page).to have_content maybe_upcase exam_level_1.name
        expect(page).to have_content exam_section_1.name
        click_link 'Start'
        expect(page).to have_content course_module_1.name
        expect(page).to have_content course_module_element_1_1.name
        expect(page).to have_content quiz_content_1.text_content
        sign_out
        print '>'
      end
    end

  end

end
