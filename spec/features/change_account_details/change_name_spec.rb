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
    activate_authlogic
  end

  scenario 'when logged in as a user', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      if this_user.corporate_customer?
        fill_in I18n.t('views.users.form.first_name'), with: "Student#{rand(9999)}"
        fill_in I18n.t('views.users.form.last_name'), with: "Individual#{rand(9999)}"
        click_button(I18n.t('views.general.save_changes'))
      elsif this_user.admin?
        expect(page).to have_content maybe_upcase "#{this_user.full_name}"
      else
        within('#personal-details') do
          fill_in I18n.t('views.users.form.first_name'), with: "Student#{rand(9999)}"
          fill_in I18n.t('views.users.form.last_name'), with: "Individual#{rand(9999)}"
          click_button(I18n.t('views.general.save'))
        end
        expect(page).to have_content I18n.t('controllers.users.update.flash.success')
      end

      sign_out
      print '>'
    end
  end

end
