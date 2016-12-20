require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their password', type: :feature do

  include_context 'users_and_groups_setup'

  before(:each) do
    a = admin_user
    b = individual_student_user
    c = corporate_student_user
    d = corporate_customer_user
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
        click_link I18n.t('views.users.show.change_your_password.link')
        within('#change_password_modal') do
          fill_in I18n.t('views.users.form.current_password'), with: this_user.password
          fill_in I18n.t('views.users.form.password_placeholder'), with: 'abcabc123'
          fill_in I18n.t('views.users.form.password_confirmation_placeholder'), with: 'abcabc123'
          click_button I18n.t('views.general.save')
        end
      else
        within('#personal-details') do
          click_link I18n.t('views.users.show.change_your_password.link')
        end
        expect(page).to have_content I18n.t('views.users.show.change_your_password.h4')
        within('#change_password_modal') do
          fill_in I18n.t('views.users.form.current_password'), with: this_user.password
          fill_in I18n.t('views.users.form.password_placeholder'), with: 'abcabc123'
          fill_in I18n.t('views.users.form.password_confirmation_placeholder'), with: 'abcabc123'
          click_button I18n.t('views.general.save')
        end
        #expect(page).to have_content I18n.t('controllers.users.change_password.flash.success')
      end

      sign_out
      print '>'
    end
  end
  sleep(10)
end
