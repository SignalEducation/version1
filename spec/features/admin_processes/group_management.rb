require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'Group management by admin: ', type: :feature do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
    a = admin_user
    b = individual_student_user
    e = comp_user
    f = content_manager_user
    g = tutor_user

    sign_in_via_sign_in_page(admin_user)
    find('.dropdown.dropdown-admin').click
    click_link(I18n.t('views.groups.index.h1'))
    expect(page).to have_content(I18n.t('views.groups.index.h1'))
  end

  describe 'successfully creates' do
    scenario 'an active Group', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name = 'Group Name 001'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name
    end

    scenario 'an in-active Group', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name = 'Group Name 002'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-002'
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to_not have_content(group_name)
      expect(page).to have_content('Learn anytime, anywhere')
    end

    scenario 'two active Groups', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name_1 = 'Group Name 001'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name_1
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name_1

      find('.dropdown.dropdown-admin').click
      click_link(I18n.t('views.groups.index.h1'))
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name_2 = 'Group Name 002'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name_2
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-002'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content('Learn anytime, anywhere')
      expect(page).to have_content group_name_1
      expect(page).to have_content group_name_2
    end

    scenario 'one active and one in-active Group', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name_1 = 'Group Name 001'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name_1
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name_1

      find('.dropdown.dropdown-admin').click
      click_link(I18n.t('views.groups.index.h1'))
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name_2 = 'Group Name 002'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name_2
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-002'
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name_1

    end

    scenario 'two in-active Groups', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name_1 = 'Group Name 001'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name_1
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content('Learn anytime, anywhere')

      find('.dropdown.dropdown-admin').click
      click_link(I18n.t('views.groups.index.h1'))
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name_2 = 'Group Name 002'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name_2
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-002'
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content('Learn anytime, anywhere')

    end

  end

  describe 'fails to create' do
    scenario 'a Group due to validation', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      expect(page).to have_content("Name can't be blank")
    end
  end

  describe 'successfully edits' do
    scenario 'a Group', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name = 'Group Name 001'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name

      find('.dropdown.dropdown-admin').click
      click_link(I18n.t('views.groups.index.h1'))

      click_link('Edit')
      expect(page).to have_content(I18n.t('views.groups.edit.h1'))
      group_name = 'Group Name 001 - edited'
      within("#edit_group_#{Group.last.id}") do
        fill_in I18n.t('views.groups.form.name'), with: group_name
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.update.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name
    end
  end

  describe 'fails to edit' do
    scenario 'a Group', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name = 'Group Name 001'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name

      find('.dropdown.dropdown-admin').click
      click_link(I18n.t('views.groups.index.h1'))

      click_link('Edit')
      expect(page).to have_content(I18n.t('views.groups.edit.h1'))
      within("#edit_group_#{Group.last.id}") do
        fill_in I18n.t('views.groups.form.name'), with: ''
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('views.groups.edit.h1'))
      expect(page).to have_content("Name can't be blank")
    end
  end

  describe 'successfully deletes' do
    scenario 'a Group', js: true do
      click_link('New')
      expect(page).to have_content(I18n.t('views.groups.new.h1'))
      group_name = 'Group Name 001'
      within('#new_group') do
        fill_in I18n.t('views.groups.form.name'), with: group_name
        fill_in I18n.t('views.groups.form.name_url'), with: 'group-name-001'
        check I18n.t('views.groups.form.active')
        fill_in I18n.t('views.groups.form.description'), with: 'ACCA Group Description'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.groups.create.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to have_content maybe_upcase group_name

      find('.dropdown.dropdown-admin').click
      click_link(I18n.t('views.groups.index.h1'))

      click_link('Delete')
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content(I18n.t('controllers.groups.destroy.flash.success'))
      expect(page).to have_content(I18n.t('views.groups.index.h1'))
      within('.navbar.navbar-default') do
        click_link('Courses')
      end
      expect(page).to_not have_content maybe_upcase group_name
      expect(page).to have_content('Learn anytime, anywhere')
    end


  end

end
