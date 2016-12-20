require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'User changing their email', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'


  let!(:country_1) { try(:country) || FactoryGirl.create(:ireland) }
  let!(:country_2) { FactoryGirl.create(:uk) }

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

  scenario 'when logged in as one of the users', js: false do
    user_list.each do |this_user|
      if this_user.corporate_user?
        switch_to_subdomain("#{corporate_organisation.subdomain}")
      else
        switch_to_main_domain
      end
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      if this_user.corporate_customer?
        fill_in I18n.t('views.users.form.address_placeholder'), with: '123 Fake Street'
        click_button(I18n.t('views.general.save_changes'))
      else
        within('#personal-details') do
          fill_in I18n.t('views.users.form.address_placeholder'), with: '123 Fake Street'
          click_button(I18n.t('views.general.save'))
        end
      end
      sign_out
      print '>'
    end
  end
  sleep(10)
end
