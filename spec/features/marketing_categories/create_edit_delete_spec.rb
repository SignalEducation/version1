require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'Create/Delete/Edit marketing categories', type: :feature do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
    sign_in_via_sign_in_page(admin_user)
  end

  describe "create category as admin" do
    scenario "with valid data", js: true do
      visit marketing_categories_path

      sleep(1)
      click_link(I18n.t('views.general.new'))
      fill_in I18n.t('views.marketing_categories.form.name'), with: "Dummy Category"

      click_button(I18n.t("views.general.save"))
      expect(page).to have_content("Dummy Category")
    end

    scenario "with invalid name", js: true do
      visit marketing_categories_path

      sleep(1)
      click_link(I18n.t('views.general.new'))
      fill_in I18n.t('views.marketing_categories.form.name'), with: "Dummy, but invalid"
      click_button(I18n.t("views.general.save"))

      expect(page).to have_content(I18n.t('views.layouts.error_messages.preface') )
    end
  end

  describe "edit category as admin" do
    scenario "with valid data", js: true do
      dummy_category = FactoryGirl.create(:marketing_category, name: "Dummy Category")

      visit marketing_categories_path

      within(:xpath, "//tr[@id='#{dummy_category.id}']") do
        click_link(I18n.t('views.general.edit'))
      end

      fill_in I18n.t('views.marketing_categories.form.name'), with: "New Dummy Category"
      click_button(I18n.t('views.general.save'))

      within(:xpath, "//tr[@id='#{dummy_category.id}']") do
        expect(page).to have_content("New Dummy Category")
      end
    end

    scenario "with invalid name", js: true do
      dummy_category = FactoryGirl.create(:marketing_category, name: "Dummy Category")

      visit marketing_categories_path

      within(:xpath, "//tr[@id='#{dummy_category.id}']") do
        click_link(I18n.t('views.general.edit'))
      end

      fill_in I18n.t('views.marketing_categories.form.name'), with: "New, Dummy Category"
      click_button(I18n.t('views.general.save'))

      expect(page).to have_content(I18n.t('views.layouts.error_messages.preface') )
    end
  end

  scenario "delete category as admin" do
    dummy_category = FactoryGirl.create(:marketing_category, name: "Dummy Category")

    visit marketing_categories_path

    within("//tr[@id='#{dummy_category.id}']") do
      click_link(I18n.t('views.general.delete'))
    end

    expect(page).to have_no_content(dummy_category.name)
  end
end
