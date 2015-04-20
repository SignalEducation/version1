require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'Admin uploading flash card packs:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  before(:each) do
    activate_authlogic
    expect(tutor_user.id).to be > 0
  end

  describe 'Uploading flash cards' do

    scenario 'uploading card and quiz content', js: true  do
      visit root_path
      click_link I18n.t('views.general.sign_in')
      within('.well.well-sm') do
        fill_in I18n.t('views.user_sessions.form.email'), with: admin_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: admin_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content I18n.t('controllers.user_sessions.create.flash.success')
      within('#navbar') do
        click_link 'Tools'
        click_link 'Course Modules'
      end
      expect(page).to have_content 'Course Modules'
      expect(page).to have_content course_module_1.name
      expect(page).to have_content course_module_element_1_1.name
      click_link 'New Flash Card Pack'
      expect(page).to have_content 'New Course Module Element'
      expect(page).to have_content 'Flash Card Pack'
      within('.well.well-sm') do
        fill_in 'Name', with: 'CME Pack 1'
        fill_in 'Description', with: 'My lovely horse running through a field'
        fill_in 'Estimated time (seconds)', with: '123'
      end
      within('.panel-heading ') do
        fill_in 'course_module_element[course_module_element_flash_card_pack_attributes][flash_card_stacks_attributes][0][name]', with: 'CME Pack 1'
        fill_in 'course_module_element[course_module_element_flash_card_pack_attributes][flash_card_stacks_attributes][0][final_button_label]', with: 'Next!'
      end
      within('.panel-body') do
        click_link 'plus-btn'
        fill_in 'course_module_element_course_module_element_flash_card_pack_attributes_flash_card_stacks_attributes_0_flash_cards_attributes_0_quiz_contents_attributes_0_text_content', with: ('AA'..'ZZ').to_a.join()
        page.find(:css, '.quiz_content_text textarea', match: :first).set('ABC' * 100)
        page.all(:css, '.quiz_content_text textarea').last.set('123' * 100)
      end

    end
  end

end
