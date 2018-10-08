require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

describe 'User changing their date of birth', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'


  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as one of the users', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile

      within('#modal-links') do
        find('.edit-details').click
      end

      within('#personal-details-form') do
        fill_in I18n.t('views.user_accounts.student_user_form.date_of_birth'), with: '20-02-1990'
        click_button(I18n.t('views.general.actual_submit'))
      end
      sign_out
      print '>'
    end
  end
end
