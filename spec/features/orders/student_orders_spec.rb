require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'The student orders process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:product_1)  { FactoryGirl.create(:product, subject_course_id: subject_course_3.id, currency_id: currency.id) }


  before(:each) do
    activate_authlogic
    visit home_path
    x = subject_course_1_home_page
    y = subject_course_3
  end

  describe 'User scourse from homepage and successfully purchases by:' do

    describe 'creating an account' do
      scenario '- Euro / Ireland /', js: true do
        click_link 'Diplomas'
        expect(page).to have_content(subject_course_3.name)
        within '.diploma_links' do
          click_on('Enroll Now')
        end
        #Create Account
        expect(page).to have_content(subject_course_3.name)
        expect(page).to have_content(product_1.price)
        expect(page).to have_content('Create Account')
        user_password = ApplicationController.generate_random_code(10)
        student_number = ApplicationController.generate_random_code(6)
        within('#sign-up-form') do
          enter_user_details('John', 'Smith', 'john@example.com', user_password)
          fill_in('user_student_number', with: student_number)
          check('user_terms')
          page.all(:css, '#signUp').first.click
          sleep 1
        end

        #Purchase Product Order
        expect(page).to have_content(subject_course_3.name)
        expect(page).to have_content(product_1.price)
        expect(page).to have_content('Payment Details')
        enter_credit_card_details('valid')
        click_on('Purchase Course')
        sleep(5)
        expect(page).to have_content(subject_course_3.name)
        expect(page).to have_content(I18n.t('controllers.orders.create.flash.success'))
        click_on maybe_upcase('Resume')
        expect(page).to have_content course_module_element_3_1.name
        within('.navbar.navbar-default') do
          click_link 'Dashboard'
        end
        expect(page).to have_content subject_course_3.name
        expect(page).to have_content 'Enrollments'
        expect(page).to have_css('.progress')
        expect(page).to have_css('.card')

      end

      scenario '- GBP / UK /', js: true do


      end

      scenario '- USD / USA /', js: true do


      end
    end

    describe 'signing into an existing account' do
      scenario '- Euro / Ireland /', js: true do


      end

      scenario '- GBP / UK /', js: true do


      end

      scenario '- USD / USA /', js: true do


      end
    end


  end




  describe 'sign-up with to free trial valid details on users#new page:' do
    describe 'Euro / Ireland /' do
      scenario 'Free Plan', js: true do
        visit new_student_path
        user_password = ApplicationController.generate_random_code(10)
        within('.login-form') do
          signup_page_student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
        end
      end
    end

    describe 'GBP / UK /' do
      scenario 'Free Plam', js: true do
        visit new_student_path
        user_password = ApplicationController.generate_random_code(10)
        within('.login-form') do
          signup_page_student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
        end
      end
    end

    describe 'USD / USA /' do
      scenario 'Free Plan', js: true do
        visit new_student_path
        user_password = ApplicationController.generate_random_code(10)
        within('.login-form') do
          signup_page_student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
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
          student_sign_up_as('D', 'Smith', nil, user_password,  false)
        end
      end

      scenario 'bad last name', js: true do
        user_password = ApplicationController.generate_random_code(10)
        within('#sign-up-form') do
          student_sign_up_as('Dan', 'S', nil, user_password, false)
        end
      end

      scenario 'bad email', js: true do
        user_password = ApplicationController.generate_random_code(10)
        student_sign_up_as('Jo', 'Ng', 'a@bcd', user_password, false)
      end
    end

  end

end
