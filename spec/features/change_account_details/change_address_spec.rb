require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their email' do

  include_context 'users_and_groups_setup'

  let!(:country_1) { FactoryGirl.create(:ireland) }
  let!(:country_2) { FactoryGirl.create(:uk) }

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as one of the users', js: false do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      within("#edit_user_#{this_user.id}") do
        fill_in I18n.t('views.users.form.address_placeholder'), with: '123 Fake Street'
        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content I18n.t('controllers.users.update.flash.success')
      if this_user.admin?
        expect(page).to have_content maybe_upcase I18n.t('views.users.index.h1')
      else
        expect(page).to have_content maybe_upcase I18n.t('views.users.show.h1')
      end
      sign_out
      print '>'
    end
  end

end
