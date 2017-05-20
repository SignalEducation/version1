require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/system_setup'
require 'support/course_content'
require 'stripe_mock'

describe 'The student sign-up process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'system_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
    visit root_path
  end

  describe 'sign-up to free trial:' do
    scenario 'with valid details on a home_page', js: false do
      user_password = ApplicationController.generate_random_code(10)
      within('#sign-up-form') do
        student_sign_up_as('John', 'Smith', 'john@example.com', user_password)
      end
      expect(page).to have_content 'Thanks for Signing Up'
    end

    scenario 'with valid details on users#new page', js: false do
      visit new_student_path
      user_password = ApplicationController.generate_random_code(10)
      within('#new_user') do
        signup_page_student_sign_up_as('John', 'Smith', 'john@example.com', user_password)
      end
      expect(page).to have_content 'Thanks for Signing Up'
    end

  end

  describe 'sign-up with problems:' do
    describe 'bad user details -' do
      scenario 'bad first name', js: false do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('D', 'Smith', nil, user_password)
        end
        expect(page).to have_content 'First name is too short (minimum is 2 characters)'
      end

      scenario 'bad last name', js: false do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('Dan', 'S', nil, user_password)
        end
        expect(page).to have_content 'Last name is too short (minimum is 2 characters)'
      end

      scenario 'bad email', js: false do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('Jo', 'Ng', 'a@bcd', user_password)
        end
        expect(page).to have_content 'Email should look like an email address'
      end
    end

  end

end
