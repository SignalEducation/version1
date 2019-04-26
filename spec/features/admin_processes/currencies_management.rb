require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/system_setup'

describe 'Currencies management by admin: ', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'system_setup'

  before(:each) do
    activate_authlogic
    sign_in_via_sign_in_page(admin_user)
    click_link 'Console'
    click_link 'System Requirements'
    click_link(I18n.t('views.currencies.index.h1'))
    expect(page).to have_content(I18n.t('views.currencies.index.h1'))
  end

  describe 'creating a Currency: ' do
    scenario 'Succeeds', js: true do
      click_link(I18n.t('views.general.new'))
      expect(page).to have_content(I18n.t('views.currencies.new.h1'))
      currency_name = 'Currency 001'
      currency_iso = 'E'
      leading_symbol = '€'
      trailing_symbol = 'c'
      within('#new_currency') do
        fill_in I18n.t('views.groups.form.name'), with: currency_name
        fill_in I18n.t('views.currencies.form.iso_code'), with: currency_iso
        fill_in I18n.t('views.currencies.form.leading_symbol'), with: leading_symbol
        fill_in I18n.t('views.currencies.form.trailing_symbol'), with: trailing_symbol
        check I18n.t('views.groups.form.active')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.currencies.create.flash.success'))
      expect(page).to have_content(I18n.t('views.currencies.index.h1'))

    end

    scenario 'Fails with validation error', js: true do
      click_link(I18n.t('views.general.new'))
      expect(page).to have_content(I18n.t('views.currencies.new.h1'))
      currency_name = ''
      currency_iso = 'E'
      leading_symbol = '€'
      trailing_symbol = 'c'
      within('#new_currency') do
        fill_in I18n.t('views.groups.form.name'), with: currency_name
        fill_in I18n.t('views.currencies.form.iso_code'), with: currency_iso
        fill_in I18n.t('views.currencies.form.leading_symbol'), with: leading_symbol
        fill_in I18n.t('views.currencies.form.trailing_symbol'), with: trailing_symbol
        check I18n.t('views.groups.form.active')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to_not have_content(I18n.t('controllers.currencies.create.flash.success'))
      expect(page).to_not have_content(I18n.t('views.currencies.index.h1'))

      expect_to_fail_validation_with(I18n.t('views.groups.form.name'))
    end

  end

  describe 'Editing a Currency: ' do
    scenario 'Succeeds', js: true do
      within('.table-responsive') do
        page.find('tr', :text => gbp.name).click_link(I18n.t('views.general.edit'))
      end

      expect(page).to have_content(I18n.t('views.currencies.edit.h1'))
      currency_name = 'Currency 002'
      within("#edit_currency_#{gbp.id}") do
        fill_in I18n.t('views.groups.form.name'), with: currency_name
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.currencies.update.flash.success'))
      expect(page).to have_content(I18n.t('views.currencies.index.h1'))
    end

    scenario 'Fails with validation error', js: true do
      within('.table-responsive') do
        page.find('tr', :text => gbp.name).click_link(I18n.t('views.general.edit'))
      end

      expect(page).to have_content(I18n.t('views.currencies.edit.h1'))
      currency_name = ''
      within("#edit_currency_#{gbp.id}") do
        fill_in I18n.t('views.groups.form.name'), with: currency_name
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to_not have_content(I18n.t('controllers.currencies.update.flash.success'))
      expect(page).to_not have_content(I18n.t('views.currencies.index.h1'))

      expect_to_fail_validation_with(I18n.t('views.groups.form.name'))
    end

  end

  describe 'Deleting a Currency' do
    scenario 'Succeeds', js: true do
      within('.table-responsive') do
        page.find('tr', :text => mxn.name).click_link(I18n.t('views.general.delete'))
      end

      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content(I18n.t('controllers.currencies.destroy.flash.success'))

    end

  end

end