require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/system_setup'
require 'support/course_content'

describe 'Navigation of footer pages', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'system_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
  end

  describe 'as a logged out user' do
    scenario 'successfully visit each footer page', js: false do
      visit home_path
      click_link 'Business'
      expect(page).to have_content "Unleash your team’s potential"

      click_link 'Why LearnSignal'
      expect(page).to have_content 'Why LearnSignal'

      visit privacy_policy_path
      expect(page).to have_content 'Privacy Policy'

      visit acca_info_path
      expect(page).to have_content 'ACCA Student Support Guidelines'

      visit contact_path
      expect(page).to have_content 'Contact Us'

      visit terms_and_conditions_path
      expect(page).to have_content 'Terms & Conditions'

      visit tutors_path
      expect(page).to have_content 'Our Lecturers'
    end
  end

  describe 'logged in as one of the users' do

    scenario 'successfully visit each footer page', js: false do
      user_list.each do |user|
        sign_in_via_sign_in_page(user)

        visit business_path
        expect(page).to have_content "Unleash your team’s potential"

        visit why_learn_signal_path
        expect(page).to have_content 'Why LearnSignal'

        visit privacy_policy_path
        expect(page).to have_content 'Privacy Policy'

        visit acca_info_path
        expect(page).to have_content 'ACCA Student Support Guidelines'

        visit contact_path
        expect(page).to have_content 'Contact Us'

        visit terms_and_conditions_path
        expect(page).to have_content 'Terms & Conditions'

        visit tutors_path
        expect(page).to have_content 'Our Lecturers'

        sign_out
      end

    end

  end

end
