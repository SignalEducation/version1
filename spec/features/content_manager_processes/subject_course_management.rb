require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'SubjectCourse management by admin/content_manager: ', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  before(:each) do
    activate_authlogic
    a = admin_user
    b = individual_student_user
    e = comp_user
    f = content_manager_user
    g = tutor_user

    sign_in_via_sign_in_page(content_manager_user)
    find('.dropdown.dropdown-normal').click
    click_link(I18n.t('views.subject_courses.index.manager_courses'))
    expect(page).to have_content(I18n.t('views.subject_courses.index.h1'))
  end

  describe 'successfully creates' do
    scenario 'an active Course', js: true do
      click_link(I18n.t('views.subject_courses.index.add_course'))
      expect(page).to have_content(I18n.t('views.subject_courses.new.h1'))
      course_name = 'Course 001'
      within('#new_subject_course') do
        select course_group_1.name, from: I18n.t('views.subject_courses.form.group_id')
        fill_in I18n.t('views.subject_courses.form.name'), with: course_name
        fill_in I18n.t('views.subject_courses.form.name_url'), with: 'course-001'
        fill_in I18n.t('views.subject_courses.form.short_description'), with: 'Course Short Description'
        fill_in I18n.t('views.subject_courses.form.quiz_pass_rate'), with: '65'
        fill_in I18n.t('views.subject_courses.form.email_content'), with: 'Welcome to the new course'
        check I18n.t('views.subject_courses.form.active')
        find('div[contenteditable]').send_keys('Course Description')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.subject_courses.create.flash.success'))
      expect(page).to have_content(I18n.t('views.subject_courses.index.h1'))

      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content course_name
    end
  end

  describe 'fails to create' do
    scenario 'a SubjectCourse due to validation', js: true do
      click_link(I18n.t('views.subject_courses.index.add_course'))
      expect(page).to have_content(I18n.t('views.subject_courses.new.h1'))
      course_name = 'Course 001'
      within('#new_subject_course') do
        select course_group_1.name, from: I18n.t('views.subject_courses.form.group_id')
        fill_in I18n.t('views.subject_courses.form.name_url'), with: 'course-001'
        fill_in I18n.t('views.subject_courses.form.short_description'), with: 'Course Short Description'
        fill_in I18n.t('views.subject_courses.form.quiz_pass_rate'), with: '65'
        fill_in I18n.t('views.subject_courses.form.email_content'), with: 'Welcome to the new course'
        check I18n.t('views.subject_courses.form.active')
        find('div[contenteditable]').send_keys('Course Description')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content("Name can't be blank")
      expect(page).to_not have_content(I18n.t('controllers.subject_courses.create.flash.success'))
      expect(page).to have_content(I18n.t('views.subject_courses.new.h1'))


      within('.navbar.navbar-default') do
        click_link(I18n.t('views.subject_courses.index.h1'))
      end
      expect(page).to_not have_content course_name

    end
  end

  describe 'successfully edits' do
    scenario 'a SubjectCourse', js: true do

      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit')
      end

      expect(page).to have_content(I18n.t('views.subject_courses.edit.h1'))
      course_name = 'Course 001 - edited'
      within("#edit_subject_course_#{subject_course_1.id}") do
        fill_in I18n.t('views.subject_courses.form.name'), with: course_name
        find('div[contenteditable]').send_keys('Course Description')
        click_button(I18n.t('views.general.save'))
      end

      expect(page).to have_content(I18n.t('controllers.subject_courses.update.flash.success'))
      expect(page).to have_content(I18n.t('views.subject_courses.index.h1'))
      within('.navbar.navbar-default') do
        click_link(I18n.t('views.subject_courses.index.h1'))
      end
      expect(page).to have_content course_name
    end
  end

  describe 'fails to edit' do
    scenario 'a SubjectCourse', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit')
      end

      expect(page).to have_content(I18n.t('views.subject_courses.edit.h1'))
      course_name = 'Course 001 - edited'
      within("#edit_subject_course_#{subject_course_1.id}") do
        fill_in I18n.t('views.subject_courses.form.name'), with: ''
        find('div[contenteditable]').send_keys('Course Description')
        click_button(I18n.t('views.general.save'))
      end

      expect(page).to have_content("Name can't be blank")
      expect(page).to_not have_content(I18n.t('controllers.subject_courses.update.flash.success'))

    end
  end

  describe 'successfully deletes' do
    scenario 'a SubjectCourse', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Delete')
      end

      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content(I18n.t('controllers.subject_courses.destroy.flash.success'))
      expect(page).to have_content(I18n.t('views.subject_courses.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to_not have_content subject_course_1.name
    end


  end

end
