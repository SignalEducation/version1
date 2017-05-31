require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'
require 'support/system_setup'

describe 'User changing their date of birth', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'course_content'
  include_context 'system_setup'


  before(:each) do
    a = admin_user
    b = individual_student_user
    e = comp_user
    f = content_manager_user
    g = tutor_user
    activate_authlogic
  end

  scenario 'when logged in as one of the users', js: false do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile

      within('#modal-links') do
        find('.edit-details').click
      end

      within('#personal-details-form') do
        fill_in I18n.t('views.users.form.date_of_birth_placeholder'), with: '20-02-1990'
        click_button(I18n.t('views.general.actual_submit'))
      end
      sign_out
      print '>'
    end
  end
end
