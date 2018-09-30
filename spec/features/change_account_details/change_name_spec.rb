require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their name', type: :feature do

  include_context 'users_and_groups_setup'

  let!(:country_1) { try(:country) || FactoryBot.create(:ireland)}
  let!(:country_2) { FactoryBot.create(:uk)}

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as a user', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile

      within('#modal-links') do
        find('.edit-details').click
      end
      sleep(2)
      within('#personal-details-form') do
        fill_in I18n.t('views.users.form.first_name'), with: "Student#{rand(9999)}"
        fill_in I18n.t('views.users.form.last_name'), with: "Individual#{rand(9999)}"
        click_button(I18n.t('views.general.actual_submit'))
      end
      sign_out
      print '>'
    end
  end
  sleep(1)
end
