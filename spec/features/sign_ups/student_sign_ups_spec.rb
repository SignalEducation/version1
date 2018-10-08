require 'rails_helper'
require 'support/users_and_groups_setup'

require 'support/system_setup'
require 'support/course_content'
require 'stripe_mock'

describe 'The student sign-up process', type: :feature do

  include_context 'users_and_groups_setup'

  include_context 'system_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
    visit root_path
  end

  describe 'sign-up to free trial:' do
    scenario 'with valid details on the home page', js: true do
      user_password = ApplicationController.generate_random_code(10)
      find('.lsbtn.open-form').click
      within('#sign_up') do
        fill_in('user_first_name', with: 'John')
        fill_in('user_last_name', with: 'Smith')
        fill_in('user_email', with: "john_#{rand(999999)}@example.com")
        fill_in('user_password', with: user_password)
        find(:css, '.check.communication_approval').click
        within('.check.terms_and_conditions') do
          find('span').click
        end

      end
      find('.lsbtn.submit').click
      expect(page).to have_content 'Thanks for Signing Up'
    end

    scenario 'with valid details on student_sign_ups#new page', js: true do
      visit new_student_path
      user_password = ApplicationController.generate_random_code(10)
      within('#new_user') do
        fill_in('user_first_name', with: 'John')
        fill_in('user_last_name', with: 'Smith')
        fill_in('user_email', with: "john_#{rand(999999)}@example.com")
        fill_in('user_password', with: user_password)
        find('.check.communication_approval').click
        within('.check.terms_and_conditions') do
          find('span').click
        end
        page.all(:css, '#signUp').first.click
      end
      expect(page).to have_content 'Thanks for Signing Up'
    end

  end

  describe 'sign-up with problems:' do
    describe 'bad user details -' do
      scenario 'bad first name', js: true do
        visit new_student_path
        user_password = ApplicationController.generate_random_code(10)
        within('#new_user') do
          fill_in('user_first_name', with: 'J')
          fill_in('user_last_name', with: 'Smith')
          fill_in('user_email', with: "john_#{rand(999999)}@example.com")
          fill_in('user_password', with: user_password)
          find('.check.communication_approval').click
          within('.check.terms_and_conditions') do
            find('span').click
          end
          page.all(:css, '#signUp').first.click
        end
        expect(page).to have_content 'First name is too short (minimum is 2 characters)'
      end

      scenario 'bad last name', js: true do
        visit new_student_path
        user_password = ApplicationController.generate_random_code(10)
        within('#new_user') do
          fill_in('user_first_name', with: 'John')
          fill_in('user_last_name', with: 'S')
          fill_in('user_email', with: "john_#{rand(999999)}@example.com")
          fill_in('user_password', with: user_password)
          find('.check.communication_approval').click
          within('.check.terms_and_conditions') do
            find('span').click
          end
          page.all(:css, '#signUp').first.click
        end
        expect(page).to have_content 'Last name is too short (minimum is 2 characters)'
      end

      scenario 'bad email', js: true do
        visit new_student_path
        user_password = ApplicationController.generate_random_code(10)
        within('#new_user') do
          fill_in('user_first_name', with: 'John')
          fill_in('user_last_name', with: 'Smith')
          fill_in('user_email', with: 'a@bcd')
          fill_in('user_password', with: user_password)
          find('.check.communication_approval').click
          within('.check.terms_and_conditions') do
            find('span').click
          end
          page.all(:css, '#signUp').first.click
        end
        expect(page).to have_content 'Email should look like an email address'
      end
    end

  end

end
