require 'rails_helper'
require 'support/users_and_groups_setup'

require 'support/system_setup'
require 'support/course_content'

describe 'User creation by admin: ', type: :feature do

  include_context 'users_and_groups_setup'

  include_context 'system_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
    a = admin_user

    sign_in_via_sign_in_page(admin_user)
    click_link 'Console'
    click_link 'Users'
    click_link I18n.t('views.general.add_user')
    expect(page).to have_content I18n.t('views.users.admin_new.h1')
    within('#new_user') do
      fill_in I18n.t('views.users.form.first_name'), with: 'First Name'
      fill_in I18n.t('views.users.form.last_name'), with: 'Last Name'
    end
  end

  describe 'creates a ' do
    scenario 'student user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'student-user@example.com'
      select student_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'comp user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'comp-user@example.com'
      select complimentary_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'tutor user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'tutor-user@example.com'
      select tutor_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'system requirements user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'system-requirements-user@example.com'
      select system_requirements_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'content_management user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'content-management-user@example.com'
      select content_management_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'stripe_management user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'stripe-management-user@example.com'
      select stripe_management_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'user_management user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'user-management-user@example.com'
      select user_management_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'developers user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'developer-user@example.com'
      select developers_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'marketing_manager user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'marketing-manager-user@example.com'
      select marketing_manager_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'user_group_manager user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'user-group-manager-user@example.com'
      select user_group_manager_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'admin user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'admin-user-user@example.com'
      select admin_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'blocked user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'blocked-user-user@example.com'
      select blocked_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end


  end


end
