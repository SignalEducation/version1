require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their email', type: :feature do

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

  scenario 'should be able to change email', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      if this_user.corporate_customer?
        fill_in I18n.t('views.users.form.email'), with: "user#{rand(9999)}@example.com"
        click_button(I18n.t('views.general.save'))
      elsif this_user.admin?
        expect(page).to have_content maybe_upcase "#{this_user.full_name}"
      else
        within('#personal-details') do
          fill_in I18n.t('views.users.form.email'), with: "user#{rand(9999)}@example.com"
          click_button(I18n.t('views.general.save'))
        end
        expect(page).to have_content I18n.t('controllers.users.update.flash.success')
      end
      sign_out
      print '>'
    end
  end

end
