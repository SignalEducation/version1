require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'Import marketing tokens from CSV file', type: :feature do

  include_context 'users_and_groups_setup'

  let!(:marketing_category) { FactoryGirl.create(:marketing_category, name: "Social Networks") }

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as admin', js: true do
    sign_in_via_sign_in_page(admin_user)
    visit marketing_tokens_path
    click_link(I18n.t('views.marketing_tokens.index.csv_upload'))
    attach_file "upload", "#{Rails.root}/spec/fixtures/files/marketing_tokens.csv"
    click_button(I18n.t('views.general.save'))

    csv_data, has_errors = MarketingToken.parse_csv(File.read("#{Rails.root}/spec/fixtures/files/marketing_tokens.csv"))
    csv_data.each_with_index do |data, index|
      expect(page).to have_xpath("//input[@value='#{data[:values][0]}']")
      expect(page).to have_xpath("//input[@value='#{data[:values][1]}']")
      expect(page).to have_xpath("//input[@value='#{data[:values][2]}']")
    end

    click_button(I18n.t('views.marketing_tokens.preview_csv.submit'))

    csv_data.each_with_index do |data, index|
      expect(page).to have_content(data[:values][0])
      expect(page).to have_content(data[:values][1])
    end
  end

end
