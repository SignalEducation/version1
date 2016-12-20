require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their name', type: :feature do

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

  scenario 'when logged in as a user', js: true do
    user_list.each do |this_user|
      if this_user.corporate_user?
        switch_to_subdomain("#{corporate_organisation.subdomain}")
      else
        switch_to_main_domain
      end
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      sleep(3)
      if this_user.corporate_customer?
        fill_in I18n.t('views.users.form.first_name'), with: "Student#{rand(9999)}"
        fill_in I18n.t('views.users.form.last_name'), with: "Individual#{rand(9999)}"
        click_button(I18n.t('views.general.save_changes'))
      else
        within('#personal-details') do
          fill_in I18n.t('views.users.form.first_name'), with: "Student#{rand(9999)}"
          fill_in I18n.t('views.users.form.last_name'), with: "Individual#{rand(9999)}"
          click_button(I18n.t('views.general.save'))
        end
      end
      sleep(1)
      sign_out
      print '>'
      sleep(1)
    end
  end
  sleep(10)
end
