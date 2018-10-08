require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/system_setup'

describe 'User changing their password', type: :feature do

  include_context 'users_and_groups_setup'

  include_context 'system_setup'

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as one of the users', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      sleep(2)
      within('#modal-links') do
        find('.change-pw-link').click
      end
      expect(page).to have_content I18n.t('views.users.show.change_your_password.h4')
      within('#change-password-form') do
        fill_in I18n.t('views.users.form.current_password'), with: this_user.password
        fill_in I18n.t('views.users.form.new_password'), with: 'abcabc123'
        fill_in I18n.t('views.user_accounts.change_password.password_confirmation'), with: 'abcabc123'
        click_button I18n.t('views.general.actual_submit')
      end
      expect(page).to have_content I18n.t('controllers.users.change_password.flash.success')
      sign_out
      print '>'
    end
  end

end
