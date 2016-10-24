require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'Create/Delete/Edit marketing tokens', type: :feature do

  include_context 'users_and_groups_setup'

  let!(:marketing_category) { FactoryGirl.create(:marketing_category, name: "Social Networks") }

  before(:each) do
    activate_authlogic
    sign_in_via_sign_in_page(admin_user)
  end

  describe "create token as admin" do
    scenario "with valid data", js: true do
      visit marketing_tokens_path

      click_link(I18n.t('views.general.new'))
      fill_in I18n.t('views.marketing_tokens.form.code'), with: "fake_token_123"
      page.find("option", text: "SEO and Direct").click

      click_button(I18n.t("views.general.save"))
      expect(page).to have_content("fake_token_123")
    end

    scenario "with invalid marketing category", js: true do
      visit marketing_tokens_path

      click_link(I18n.t('views.general.new'))
      fill_in I18n.t('views.marketing_tokens.form.code'), with: "fake_token_123"

      click_button(I18n.t("views.general.save"))
      expect(page).to have_content(I18n.t('views.layouts.error_messages.preface') )
    end

    scenario "with invalid token code", js: true do
      visit marketing_tokens_path

      click_link(I18n.t('views.general.new'))
      fill_in I18n.t('views.marketing_tokens.form.code'), with: "fake_token 123"

      page.find("option", text: "SEO and Direct").click

      click_button(I18n.t("views.general.save"))
      expect(page).to have_content(I18n.t('views.layouts.error_messages.preface') )
    end
  end

  describe "edit token as admin" do
    scenario "with valid data", js: true do
      dummy_category = FactoryGirl.create(:marketing_category, name: "Dummy Category")
      token =  FactoryGirl.create(:marketing_token, marketing_category_id: marketing_category.id, is_hard: false)

      visit marketing_tokens_path

      within(:xpath, "//tr[@id='#{token.id}']") do
        click_link(I18n.t('views.general.edit'))
      end

      check("marketing_token_is_hard")
      page.find("option", text: "Dummy Category").click
      click_button(I18n.t('views.general.save'))

      within(:xpath, "//tr[@id='#{token.id}']") do
        expect(page).to have_content("Dummy Category")
        #expect(page).to have_css("span.glyphicon-ok")
      end
    end

    scenario "with invalid marketing category", js: true do
      token =  FactoryGirl.create(:marketing_token, marketing_category_id: marketing_category.id, is_hard: false)

      visit marketing_tokens_path

      within(:xpath, "//tr[@id='#{token.id}']") do
        click_link(I18n.t('views.general.edit'))
      end

      page.find("option", text: "Select...").click
      click_button(I18n.t('views.general.save'))

      expect(page).to have_content(I18n.t('views.layouts.error_messages.preface') )
    end
  end

  scenario "delete token as admin" do
    token =  FactoryGirl.create(:marketing_token, marketing_category_id: marketing_category.id, is_hard: false)

    visit marketing_tokens_path

    within("//tr[@id='#{token.id}']") do
      click_link(I18n.t('views.general.delete'))
    end

    expect(page).to have_no_content(token.code)
  end
end
