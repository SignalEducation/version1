require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/system_setup'
require 'support/course_content'

describe 'User creation by admin: ', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'system_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
    a = admin_user
    b = individual_student_user
    c = content_manager_user
    d = blogger_user
    e = comp_user
    f = customer_support_manager_user
    g = tutor_user
    h = marketing_manager_user

    sign_in_via_sign_in_page(admin_user)
    visit users_path
    click_link I18n.t('views.general.add_user')
    expect(page).to have_content I18n.t('views.users.admin_new.h1')
    within('#new_user') do
      check I18n.t('views.users.form.active')
      fill_in I18n.t('views.users.form.first_name'), with: 'First Name'
      fill_in I18n.t('views.users.form.last_name'), with: 'Last Name'
      select ireland.name, from: I18n.t('views.users.form.country_id')
    end
  end

  describe 'creates a ' do
    scenario 'student user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'student-user@example.com'
      select individual_student_user_group.name, from: I18n.t('views.users.form.user_group_id')
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

    scenario 'content manager user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'content-user@example.com'
      select content_manager_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'blogger user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'blogger-user@example.com'
      select blogger_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'marketing manager user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'marketing-user@example.com'
      select marketing_manager_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end

    scenario 'customer support user', js: false do
      fill_in I18n.t('views.users.form.email'), with: 'customer-support-user@example.com'
      select customer_support_user_group.name, from: I18n.t('views.users.form.user_group_id')
      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.users.create.flash.success'))
    end


  end


end
