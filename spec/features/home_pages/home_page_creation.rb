require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'
require 'support/system_setup'

describe 'Home Page Creation', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'course_content'
  include_context 'system_setup'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
  end

  describe 'Non Logged-In User' do
    scenario 'gets bounced as not logged-in', js: true do
      visit home_pages_path
      expect(page).to have_content(I18n.t('controllers.application.logged_in_required.flash_error'))
      expect(page).to have_content(I18n.t('views.user_sessions.new.h1'))
    end
  end

  describe 'Non Admin User' do
    scenario 'gets bounced as not allowed', js: true do
      user_list.delete(admin_user)
      user_list.each do |this_user|
        sign_in_via_sign_in_page(this_user)
        visit home_pages_path
        expect(page).to have_content(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(page).to have_content(I18n.t('views.dashboard.student.h1'))
        sign_out
      end
    end
  end

  describe 'Admin User' do
    before(:each) do
      a = admin_user
      b = individual_student_user
      e = comp_user
      f = content_manager_user
      g = tutor_user

      activate_authlogic
      sign_in_via_sign_in_page(admin_user)
      visit home_pages_path
      sleep(1)
      expect(page).to have_content(I18n.t('views.home_pages.index.h1'))
    end

    scenario 'create a homepage associated with a subject course', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.home_pages.new.h1'))
      expect(page).to have_content(I18n.t('views.home_pages.form.seo_title'))
      within('#new_home_page') do
        fill_in I18n.t('views.home_pages.form.seo_title'), with: 'New Page Seo Title'
        fill_in I18n.t('views.home_pages.form.seo_description'), with: 'New Page Seo Description'
        fill_in I18n.t('views.home_pages.form.public_url'), with: 'new-page'
        select subject_course_1.name, from: I18n.t('views.home_pages.form.subject_course_id')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.home_pages.create.flash.success'))
      expect(page).to have_content(I18n.t('views.home_pages.index.h1'))
      sign_out
      visit '/new-page'
      expect(page).to have_content(subject_course_1.name)
    end

    scenario 'create a homepage associated with a group', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.home_pages.new.h1'))
      expect(page).to have_content(I18n.t('views.home_pages.form.seo_title'))
      within('#new_home_page') do
        fill_in I18n.t('views.home_pages.form.seo_title'), with: 'New Page Seo Title'
        fill_in I18n.t('views.home_pages.form.seo_description'), with: 'New Page Seo Description'
        fill_in I18n.t('views.home_pages.form.public_url'), with: 'new-page'
        select course_group_1.name, from: I18n.t('views.home_pages.form.group_id')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.home_pages.create.flash.success'))
      expect(page).to have_content(I18n.t('views.home_pages.index.h1'))
      sign_out
      visit '/new-page'
      expect(page).to have_content(course_group_1.name)
    end

    scenario 'creates a custom view homepage', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.home_pages.new.h1'))
      expect(page).to have_content(I18n.t('views.home_pages.form.seo_title'))
      within('#new_home_page') do
        fill_in I18n.t('views.home_pages.form.seo_title'), with: 'New Page Seo Title'
        fill_in I18n.t('views.home_pages.form.seo_description'), with: 'New Page Seo Description'
        fill_in I18n.t('views.home_pages.form.public_url'), with: 'acca'
        select subject_course_1.name, from: I18n.t('views.home_pages.form.subject_course_id')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.home_pages.create.flash.success'))
      expect(page).to have_content(I18n.t('views.home_pages.index.h1'))
      sign_out
      visit '/acca'
      expect(page).to have_content(('Prepare for your ACCA exams with an online course').upcase)
    end

    scenario 'create a homepage associated with a subscription plan category', js: true do
      #Currently not accurate because were not using this feature
      click_link('New')
      expect(page).to have_content(I18n.t('views.home_pages.new.h1'))
      expect(page).to have_content(I18n.t('views.home_pages.form.seo_title'))
      within('#new_home_page') do
        fill_in I18n.t('views.home_pages.form.seo_title'), with: 'New Page Seo Title'
        fill_in I18n.t('views.home_pages.form.seo_description'), with: 'New Page Seo Description'
        fill_in I18n.t('views.home_pages.form.public_url'), with: 'new-page'
        select course_group_1.name, from: I18n.t('views.home_pages.form.group_id')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.home_pages.create.flash.success'))
      expect(page).to have_content(I18n.t('views.home_pages.index.h1'))
      sign_out
      visit '/new-page'
      expect(page).to have_content(course_group_1.name)
    end

    scenario 'fails to create a homepage due validation', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.home_pages.new.h1'))
      expect(page).to have_content(I18n.t('views.home_pages.form.seo_title'))
      within('#new_home_page') do
        fill_in I18n.t('views.home_pages.form.seo_title'), with: subject_course_1_home_page.seo_title
        fill_in I18n.t('views.home_pages.form.seo_description'), with: 'New Page Seo Description'
        fill_in I18n.t('views.home_pages.form.public_url'), with: 'new-page'
        select course_group_1.name, from: I18n.t('views.home_pages.form.group_id')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.home_pages.create.flash.error'))
      expect(page).to have_content(I18n.t('views.home_pages.new.h1'))
    end

  end
end
