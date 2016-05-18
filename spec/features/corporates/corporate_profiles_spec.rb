require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'


describe 'Corp User:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:corporation_1) { FactoryGirl.create(:corporate_customer) }

  before(:each) do
    activate_authlogic
    switch_to_subdomain("#{corporation_1.subdomain}")
    visit root_path
    x = corporate_student_user.id
  end

  describe 'signs in' do

    scenario 'as a corporate manager', js: true  do
      click_link('Login')
      fill_in_sign_in_form(corporate_customer_user)

      expect(page).to have_content 'Overview'
      expect(page).to have_content 'User Activity'
      expect(page).to have_content 'Compulsory Courses'
      expect(page).to have_content 'Other Courses'
    end

    scenario 'as a corporate student', js: true  do
      click_link('Login')
      fill_in_sign_in_form(corporate_student_user)
      expect(page).to have_content 'LEARN ANYTIME, ANYWHERE'
    end

  end

  describe 'creates profile' do

    scenario 'by first verifying they belong to the corporate', js: true  do
      click_link('Create Account')
      expect(page).to have_content "Verify you belong to #{corporation_1.organisation_name}"
      fill_in_corp_verification_form(corporation_1)
      expect(page).to have_content 'Already have an account? Sign In Here'
      within('.login-form') do
        user_password = ApplicationController.generate_random_code(10)
        enter_user_details('John', 'Smith', 'john@example.com', user_password)
        fill_in('user_employee_guid', with: '123abc')
        click_button('Create Account')
      end
      expect(page).to have_content "You are making good progress, #{corporate_student_user.first_name}!"
    end

  end

end
