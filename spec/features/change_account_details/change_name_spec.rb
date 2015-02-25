require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their name' do

  include_context 'users_and_groups_setup'

  let!(:country_1) { FactoryGirl.create(:ireland)}
  let!(:country_2) { FactoryGirl.create(:uk)}

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as a user', js: false do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      within('#personal-details') do
        fill_in I18n.t('views.users.form.first_name'), with: "Student#{rand(9999)}"
        fill_in I18n.t('views.users.form.last_name'), with: "Individual#{rand(9999)}"
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content I18n.t('controllers.users.update.flash.success')
      this_user.admin? ?
              expect(page).to(have_content(maybe_upcase(I18n.t('views.users.index.h1')))) :
              expect(page).to(have_content(maybe_upcase(I18n.t('views.users.show.h1'))))
      sign_out
      print '>'
    end
  end

end
