require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their password' do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as one of the users', js: false do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      within('#personal-details') do
        click_link I18n.t('views.users.show.change_your_password.link')
      end
      expect(page).to have_content I18n.t('views.users.show.change_your_password.h4')
      within('#change_password_modal') do
        fill_in I18n.t('views.users.form.current_password'), with: this_user.password
        fill_in I18n.t('views.users.form.password'), with: 'abcabc123'
        fill_in I18n.t('views.users.form.password_confirmation'), with: 'abcabc123'
        click_button I18n.t('views.general.save')
      end
      expect(page).to have_content I18n.t('controllers.users.change_password.flash.success')
      sign_out
      print '>'
    end
  end

end
