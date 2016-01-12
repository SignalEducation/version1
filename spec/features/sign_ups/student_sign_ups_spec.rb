require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'

describe 'The student sign-up process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
    visit root_path
  end

  #### The Successful Path
  describe 'sign-up with to free trial valid details:' do
    describe 'Euro / Ireland /' do
      scenario 'Free Plan', js: true do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('John', 'Smith', nil, user_password, ireland, true)
        end
      end
    end

    describe 'GBP / UK /' do
      scenario 'Free Plam', js: true do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('John', 'Smith', nil, user_password, uk, true)
        end
      end
    end

    describe 'USD / USA /' do
      scenario 'Free Plan', js: true do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('John', 'Smith', nil, user_password, usa, true)
        end
      end
    end
  end

  #### The Unsuccessful path
  describe 'sign-up with problems:' do
    describe 'bad user details -' do
      scenario 'bad first name', js: true do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('D', 'Smith', nil, user_password, ireland, false)
        end
      end

      scenario 'bad last name', js: true do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('Dan', 'S', nil, user_password, ireland, false)
        end
      end

      scenario 'bad email', js: true do
        user_password = ApplicationController.generate_random_code(10)
        student_sign_up_as('Jo', 'Ng', 'a@bcd', user_password, ireland, false)
      end
    end

  end

end
