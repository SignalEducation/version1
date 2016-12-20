require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their email', type: :feature do

  include_context 'users_and_groups_setup'

  let!(:country_1) { try(:country) || FactoryGirl.create(:ireland)}
  let!(:country_2) { FactoryGirl.create(:uk)}

  before(:each) do
    a = admin_user
    b = individual_student_user
    c = corporate_student_user
    d = corporate_customer_user
    e = comp_user
    f = content_manager_user
    g = tutor_user
    activate_authlogic
  end

  scenario 'should be able to change email', js: true do
    user_list.each do |this_user|
      if this_user.corporate_user?
        switch_to_subdomain("#{corporate_organisation.subdomain}")
      else
        switch_to_main_domain
      end
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      if this_user.corporate_customer?
        fill_in I18n.t('views.users.form.email'), with: "user#{rand(9999)}@example.com"
        click_button(I18n.t('views.general.save'))
      else
        within('#personal-details') do
          fill_in I18n.t('views.users.form.email'), with: "user#{rand(9999)}@example.com"
          click_button(I18n.t('views.general.save'))
        end
      end
      find('.dropdown.dropdown-normal').click
      click_link(I18n.t('views.general.sign_out'))
      if this_user.corporate_user?
        expect(page).to have_content ('Please Login or Create an account')
      else
        expect(page).to have_content maybe_upcase(I18n.t('views.general.sign_in'))
      end
      print '>'
      sleep(1)
    end
  end

end
