require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'

describe 'Course content Vs Paywall', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  describe 'Anonymous user' do
    scenario 'can see free content', js: true do
      visit library_path
      click_link('ACA1')
      click_link('Start')
      sleep 20
    end

    scenario 'cannot see protected content', js: true do

    end
  end

  describe 'Signed in as' do
    before(:each) do
      activate_authlogic
      visit root_path
      click_link I18n.t('views.general.sign_up')
      expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
    end

    describe 'a student user' do
      scenario 'should see free content', js: true do

      end

      scenario 'should see paid content', js: true do

      end
    end

    describe 'cancelled student' do
      scenario 'should see free content', js: true do

      end

      scenario 'should not see paid content', js: true do

      end
    end

    describe 'arrears student' do
      scenario 'should see free content', js: true do

      end

      scenario 'should not see paid content', js: true do

      end
    end

  end
end
