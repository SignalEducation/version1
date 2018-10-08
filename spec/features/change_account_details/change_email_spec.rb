require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

describe 'User changing their email', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end

  scenario 'should be able to change email', js: false do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile

      within('#modal-links') do
        find('.edit-details').click
      end

      within('#personal-details-form') do
        fill_in I18n.t('views.users.form.email'), with: "user#{rand(9999)}@example.com"
        click_button(I18n.t('views.general.actual_submit'))
      end
      sign_out
      print '>'
    end
  end
end
