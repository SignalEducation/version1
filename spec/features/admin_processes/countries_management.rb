require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/system_setup'

describe 'Currencies management by admin: ', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'system_setup'

  before(:each) do
    activate_authlogic
    a = admin_user
    b = individual_student_user
    e = comp_user
    f = content_manager_user
    g = tutor_user

    sign_in_via_sign_in_page(admin_user)
    find('.dropdown.dropdown-normal').click
    click_link(I18n.t('views.countries.index.h1'))
    expect(page).to have_content(I18n.t('views.countries.index.h1'))
  end

  describe 'creating a Country: ' do
    scenario 'Succeeds', js: true do
      click_link(I18n.t('views.general.new'))
      expect(page).to have_content(I18n.t('views.countries.new.h1'))
      country_name = 'Country 001'
      country_iso = 'EE'
      country_tld = '.rf'
      within('#new_country') do
        fill_in I18n.t('views.countries.form.name'), with: country_name
        fill_in I18n.t('views.countries.form.iso_code'), with: country_iso
        fill_in I18n.t('views.countries.form.country_tld'), with: country_tld
        select eur.name, from: I18n.t('views.countries.form.currency_id')
        select 'Europe', from: I18n.t('views.countries.form.continent')
        check I18n.t('views.countries.form.in_the_eu')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.countries.create.flash.success'))
      expect(page).to have_content(I18n.t('views.countries.index.h1'))

    end

    scenario 'Fails', js: true do
      click_link(I18n.t('views.general.new'))
      expect(page).to have_content(I18n.t('views.countries.new.h1'))
      country_name = ''
      country_iso = 'EE'
      country_tld = '.rf'
      within('#new_country') do
        fill_in I18n.t('views.countries.form.name'), with: country_name
        fill_in I18n.t('views.countries.form.iso_code'), with: country_iso
        fill_in I18n.t('views.countries.form.country_tld'), with: country_tld
        select eur.name, from: I18n.t('views.countries.form.currency_id')
        select 'Europe', from: I18n.t('views.countries.form.continent')
        check I18n.t('views.countries.form.in_the_eu')
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to_not have_content(I18n.t('controllers.countries.create.flash.success'))
      expect(page).to_not have_content(I18n.t('views.countries.index.h1'))

      expect_to_fail_validation_with(I18n.t('views.countries.form.name'))
    end

  end

  describe 'Editing a Country: ' do
    scenario 'Succeeds', js: true do
      within('.table-responsive') do
        page.find('tr', :text => usa.name).click_link(I18n.t('views.general.edit'))
      end

      expect(page).to have_content(I18n.t('views.countries.edit.h1'))
      country_name = 'Country 002'
      within("#edit_country_#{usa.id}") do
        fill_in I18n.t('views.groups.form.name'), with: country_name
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.countries.update.flash.success'))
      expect(page).to have_content(I18n.t('views.countries.index.h1'))
    end

    scenario 'Fails', js: true do
      within('.table-responsive') do
        page.find('tr', :text => usa.name).click_link(I18n.t('views.general.edit'))
      end

      expect(page).to have_content(I18n.t('views.countries.edit.h1'))
      country_name = ''
      within("#edit_country_#{usa.id}") do
        fill_in I18n.t('views.countries.form.name'), with: country_name
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to_not have_content(I18n.t('controllers.countries.update.flash.success'))
      expect(page).to_not have_content(I18n.t('views.countries.index.h1'))

      expect_to_fail_validation_with(I18n.t('views.countries.form.name'))
    end

  end

  describe 'Deleting a Country' do
    scenario 'Succeeds', js: true do
      within('.table-responsive') do
        page.find('tr', :text => fr.name).click_link(I18n.t('views.general.delete'))
      end

      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content(I18n.t('controllers.countries.destroy.flash.success'))

    end

  end

end