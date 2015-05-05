require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'Create/Delete/Edit marketing tokens', type: :feature do

  include_context 'users_and_groups_setup'

  let!(:marketing_category) { FactoryGirl.create(:marketing_category, name: "Social Networks") }

  before(:each) do
    activate_authlogic
  end

  scenario "create token as admin", js: true do
    sign_in_via_sign_in_page(admin_user)
    visit marketing_tokens_path

    click_link(I18n.t('views.general.new'))
    fill_in I18n.t('views.marketing_tokens.form.code'), with: "abc fake token"
    page.find("option", text: "SEO and Direct").click

    click_button(I18n.t("views.general.save"))
    expect(page).to have_content("abc fake token")
  end

  scenario "edit token as admin" do
    token =  FactoryGirl.create(:marketing_token, marketing_category_id: marketing_category.id, is_hard: false)

    sign_in_via_sign_in_page(admin_user)
    visit marketing_tokens_path

    within("tr##{token.id}") do
      click_link(I18n.t('views.general.edit'))
    end

    check("marketing_token_is_hard")
    click_button(I18n.t('views.general.save'))

    within("tr##{token.id}") do
      expect(page).to have_css("span.glyphicon-ok")
    end
  end

  scenario "delete token as admin" do
    token =  FactoryGirl.create(:marketing_token, marketing_category_id: marketing_category.id, is_hard: false)

    sign_in_via_sign_in_page(admin_user)
    visit marketing_tokens_path

    within("//tr[@id='#{token.id}']") do
      click_link(I18n.t('views.general.delete'))
    end

    expect(page).to have_no_content(token.code)
  end
end
