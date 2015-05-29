require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'Referral codes modal dialog', type: :feature do
  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end

  describe 'check Refer a friend link' do
    scenario 'when logged in as user who is allowed to have referral code', js: true do
      [individual_student_user, corporate_student_user, tutor_user].each do |usr|
        sign_in_via_sign_in_page(usr)
        expect(page).to have_content("Refer a friend!")
        sign_out
      end
    end

    scenario 'when logged in as user who is not allowed to have referral code', js: true do
      [admin_user,
       content_manager_user,
       blogger_user,
       corporate_customer_user,
       forum_manager_user].each do |usr|
        sign_in_via_sign_in_page(usr)
        expect(page).not_to have_content("Refer a friend!")
        sign_out
      end
    end
  end

  describe 'getting and copying the referral code' do
    scenario 'get referral code', js: true do
      sign_in_via_sign_in_page(tutor_user)
      click_link('Refer a friend!')
      # We have to check content like this because on dialog opening
      # Ajax request is sent to server. Till request is processed
      # database cleaner will already clean database and referral code
      # will not be created.
      url = find("#code").value
      expect(url[-7..-1]).to eq(ReferralCode.first.code[-7..-1])
    end
  end

end
