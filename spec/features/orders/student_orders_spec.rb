require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/subscription_plans_setup'

describe 'The student orders process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup'

  let!(:product_1)  { FactoryGirl.create(:product, subject_course_id: subject_course_3.id, currency_id: gbp.id) }


  before(:each) do
    activate_authlogic
    visit home_path
    x = subject_course_1_home_page
    y = subject_course_3
  end

  describe 'User selects course from homepage and successfully purchases by:' do

    describe 'User purchases a product' do
      scenario 'while creating an account', js: true do
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
        find('.resume').click
        expect(page).to have_content course_module_element_3_1.name
        within('.navbar.navbar-default') do
          click_link 'Dashboard'
        end
        expect(page).to have_content subject_course_3.name
        expect(page).to have_content 'Enrollments'
        expect(page).to have_css('.progress')
        expect(page).to have_css('.card')

        find('.dropdown.dropdown-normal').click
        click_link('Account')
        expect(page).to have_content(I18n.t('views.users.show.tabs.orders'))
        expect(page).to have_content('Account Info')
        click_on(I18n.t('views.users.show.tabs.orders'))
        expect(page).to have_content(subject_course_3.name)
        expect(page).to have_content(product_1.price)
        expect(page).to have_content('Paid')

      end
    end

  end

  describe 'User purchases a product after' do
    scenario 'signing up for free trial', js: true do
      visit new_student_path
      user_password = ApplicationController.generate_random_code(10)
      within('.login-form') do
        signup_page_student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
      end
      expect(page).to have_content 'Final Step!'
      expect(page).to have_content "To complete your membership we need to verify that we're sending emails to the correct address."

      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      expect(page).to have_content maybe_upcase course_group_1.name
      expect(page).to have_content course_group_1.description
      click_link("#{course_group_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link("#{subject_course_1.name}")
      expect(page).to have_content subject_course_1.name
      expect(page).to have_content('Upgrade Your Account for Full Access.')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content course_module_element_1_1.name
      find('.dropdown.dropdown-normal').click
      click_link('Account')
      expect(page).to have_content('Account Info')
      sign_out
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'john@example.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: user_password
        click_button I18n.t('views.general.sign_in')
        sleep 1
      end

      click_link 'Diplomas'
      expect(page).to have_content(subject_course_3.name)
      within '.diploma_links' do
        click_on('Enroll Now')
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
      find('.resume').click
      expect(page).to have_content course_module_element_3_1.name
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end
      expect(page).to have_content subject_course_3.name
      expect(page).to have_content 'Enrollments'
      expect(page).to have_css('.progress')
      expect(page).to have_css('.card')

      find('.dropdown.dropdown-normal').click
      click_link('Account')
      expect(page).to have_content(I18n.t('views.users.show.tabs.orders'))
      expect(page).to have_content('Account Info')
      click_on(I18n.t('views.users.show.tabs.orders'))
      expect(page).to have_content(subject_course_3.name)
      expect(page).to have_content(product_1.price)
      expect(page).to have_content('Paid')

    end
  end

  describe 'User purchases a product after' do
    scenario 'signing up for free trial and upgrading to a subscription', js: true do
      visit new_student_path
      user_password = ApplicationController.generate_random_code(10)
      within('.login-form') do
        signup_page_student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
      end

      within('#thank-you-message') do
        expect(page).to have_content 'Final Step!'
        expect(page).to have_content "To complete your membership we need to verify that we're sending emails to the correct address."
      end
      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      expect(page).to have_content maybe_upcase course_group_1.name
      expect(page).to have_content course_group_1.description
      click_link("#{course_group_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link("#{subject_course_1.name}")
      expect(page).to have_content subject_course_1.name
      expect(page).to have_content('Upgrade Your Account for Full Access.')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content course_module_element_1_1.name

      within('.navbar.navbar-default') do
        find('.days-left').click
      end

      expect(page).to have_content 'Upgrade your membership'
      student_picks_a_subscription_plan(gbp, 1)
      enter_credit_card_details('valid')
      check(I18n.t('views.general.terms_and_conditions'))
      find('.upgrade-sub').click
      sleep(10)
      expect(page).to have_content 'Thanks for upgrading your subscription!'
      visit_my_profile
      click_on 'Subscription Info'
      expect(page).to have_content 'Account Status: Valid Subscription'
      expect(page).to have_content 'Billing Interval:   Monthly'

      within('.navbar.navbar-default') do
        click_link 'Courses'
      end

      expect(page).to have_content maybe_upcase course_group_1.name
      expect(page).to have_content course_group_1.description
      click_link("#{course_group_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link("#{subject_course_1.name}")
      expect(page).to have_content subject_course_1.name
      expect(page).to_not have_content('Upgrade Your Account for Full Access.')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content course_module_element_1_1.name
      find('.dropdown.dropdown-normal').click
      click_link('Account')
      expect(page).to have_content('Account Info')
      sign_out

      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'john@example.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: user_password
        click_button I18n.t('views.general.sign_in')
        sleep 1
      end

      click_link 'Diplomas'
      expect(page).to have_content(subject_course_3.name)
      within '.diploma_links' do
        click_on('Enroll Now')
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

      find('.dropdown.dropdown-normal').click
      click_link('Account')
      expect(page).to have_content(I18n.t('views.users.show.tabs.orders'))
      expect(page).to have_content('Account Info')
      click_on(I18n.t('views.users.show.tabs.orders'))
      expect(page).to have_content(subject_course_3.name)
      expect(page).to have_content(product_1.price)
      expect(page).to have_content('Paid')

    end
  end

  describe 'User purchases a product after' do
    scenario 'then adds a subscription to their account', js: true do
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

      find('.dropdown.dropdown-normal').click
      click_link('Account')
      expect(page).to have_content(I18n.t('views.users.show.tabs.orders'))
      expect(page).to have_content('Account Info')
      click_on(I18n.t('views.users.show.tabs.orders'))
      expect(page).to have_content(subject_course_3.name)
      expect(page).to have_content(product_1.price)
      expect(page).to have_content('Paid')


      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      expect(page).to have_content maybe_upcase course_group_1.name
      expect(page).to have_content course_group_1.description
      click_link("#{course_group_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link("#{subject_course_1.name}")
      expect(page).to have_content subject_course_1.name
      expect(page).to have_content('A Subscription is required to access this content')

      click_link('Upgrade to Subscription')

      expect(page).to have_content 'Upgrade your membership'
      student_picks_a_subscription_plan(gbp, 1)
      enter_credit_card_details('valid')
      find('.upgrade-sub').click
      sleep(8)

      expect(page).to have_content 'Thanks for upgrading your subscription!'
      visit_my_profile
      click_on 'Subscription Info'
      expect(page).to have_content 'Account Status: Valid Subscription'
      expect(page).to have_content 'Billing Interval:   Monthly'
      sign_out

      visit sign_in_path

      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'john@example.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: user_password
        click_button I18n.t('views.general.sign_in')
        sleep 1
      end

      within('.navbar.navbar-default') do
        click_link 'Courses'
      end

      expect(page).to have_content maybe_upcase course_group_1.name
      expect(page).to have_content course_group_1.description
      click_link("#{course_group_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link("#{subject_course_1.name}")
      expect(page).to have_content subject_course_1.name
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content course_module_element_1_1.name
      find('.dropdown.dropdown-normal').click
      click_link('Account')
      expect(page).to have_content('Account Info')
      sign_out

    end
  end


end
