require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

describe 'User changing their name', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'


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

      within('#personal-details-form') do
        fill_in I18n.t('views.users.form.first_name'), with: "Student#{rand(9999)}"
        fill_in I18n.t('views.users.form.last_name'), with: "Individual#{rand(9999)}"
        click_button(I18n.t('views.general.actual_submit'))
      end
      sign_out
      print '>'
    end
  end

end
