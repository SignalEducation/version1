require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their email', type: :feature do

  include_context 'users_and_groups_setup'

  let!(:country_1) { try(:country) || FactoryGirl.create(:ireland)}
  let!(:country_2) { FactoryGirl.create(:uk)}

  before(:each) do
    a = admin_user
    b = individual_student_user
    e = comp_user
    f = content_manager_user
    g = tutor_user
    activate_authlogic
  end

  scenario 'should be able to change email', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      within('#personal-details') do
        fill_in I18n.t('views.users.form.email'), with: "user#{rand(9999)}@example.com"
        click_button(I18n.t('views.general.save'))
      end
      sleep(3)
      find('.dropdown.dropdown-normal').click
      click_link(I18n.t('views.general.sign_out'))
      expect(page).to have_content 'SIGN IN'
      print '>'
    end
  end
  sleep(10)
end
