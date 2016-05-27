# Some methods that are auto_loaded by rails_helper.rb into every RSpec test.

######
## features
##

#### Generic

def maybe_upcase(thing)
  thing
  #Capybara.current_driver == Capybara.javascript_driver ? thing.upcase : thing
end


#### Signing in and out, and 'my profile'

def sign_in_via_sign_in_page(user)
  visit sign_in_path
  within('#sign-in') do
    fill_in I18n.t('views.user_sessions.form.email'), with: user.email
    fill_in I18n.t('views.user_sessions.form.password'), with: user.password
    click_button I18n.t('views.general.sign_in')
  end
end

def fill_in_sign_in_form(user)
  within('#sign-in') do
    fill_in I18n.t('views.user_sessions.form.email'), with: user.email
    fill_in I18n.t('views.user_sessions.form.password'), with: user.password
    click_button I18n.t('views.general.sign_in')
  end
end

def fill_in_corp_verification_form(corp)
  within('.login-form') do
    fill_in I18n.t('views.user_sessions.form.user_name'), with: corp.user_name
    fill_in I18n.t('views.user_sessions.form.password'), with: corp.passcode
    click_button I18n.t('views.general.enter')
  end
end

def sign_out
  find('.dropdown.dropdown-normal').click
  click_link(I18n.t('views.general.sign_out'))
end

def visit_my_profile
  within('.navbar.navbar-default') do
    find('.dropdown-normal').click
    click_link(I18n.t('views.users.show.h1'))
  end
end

#### Student sign_up process

def student_sign_up_as(user_first_name, user_second_name, user_email, user_password, expect_sign_up)
  enter_user_details(user_first_name, user_second_name, user_email, user_password)
  expect(page).to have_content 'SIGN UP FOR YOUR 7-DAY FREE TRIAL'
  page.all(:css, '#signUp').first.click
  sleep 1
  if expect_sign_up

  else

  end
end

def signup_page_student_sign_up_as(user_first_name, user_second_name, user_email, user_password, expect_sign_up)
  enter_user_details(user_first_name, user_second_name, user_email, user_password)
  page.all(:css, '#signUp').first.click
  sleep 1
  if expect_sign_up

  else

  end
end

def enter_card_details(card, cvv, exp_month, exp_year)
  fill_in('card_number', with: card)
  fill_in('cvv_number', with: cvv)
  select exp_month, from: 'expiry_month'
  select exp_year, from: 'expiry_year'
end

def enter_credit_card_details(card_type='valid')
  # see https://stripe.com/docs/testing
  expect(%w(valid valid_visa_debit valid_mc_debit expired bad_cvc declined bad_number processing_error).include?(card_type)).to eq(true)
  case card_type
    when 'valid'
      enter_card_details('4242424242424242','123','12',Time.now.year + 1)
    when 'valid_visa_debit'
      enter_card_details('4000056655665556','123','12',Time.now.year + 1)
    when 'valid_mc_debit'
      enter_card_details('5200828282828210','123','12',Time.now.year + 1)
    when 'expired'
      enter_card_details('4000000000000069','123','12',Time.now.year + 1) # assumes the date is wrong
    when 'bad_cvc'
      enter_card_details('4000000000000127','123','12',Time.now.year + 1)
    when 'declined'
      enter_card_details('4000000000000002','123','12',Time.now.year + 1)
    when 'bad_number'
      enter_card_details('4242424242424241','123','12',Time.now.year + 1)
    when 'processing_error'
      enter_card_details('4000000000000119','123','12',Time.now.year + 1)
    else
      enter_card_details('4242424242424242','123','12',Time.now.year)
  end
end

def enter_user_details(first_name, last_name, email=nil, user_password)
  fill_in('user_first_name', with: first_name)
  fill_in('user_last_name', with: last_name)
  fill_in('user_email', with: email || "#{first_name.downcase}_#{rand(999999)}@example.com")
  fill_in('user_password', with: user_password)
end

def student_picks_a_subscription_plan(currency, payment_frequency)
  expect([1,3,12].include?(payment_frequency)).to eq(true)
  find("#sub-#{currency.iso_code.upcase}-#{payment_frequency}").click
  within("#sub-#{currency.iso_code.upcase}-#{payment_frequency}") do
    find('.plan-option').click
  end
end

def sign_up_and_upgrade_from_free_trial
  visit root_path
  user_password = ApplicationController.generate_random_code(10)
  sleep(2)
  within('#sign-up-form') do
    student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
  end
  sleep(2)
  within('#thank-you-message') do
    expect(page).to have_content 'Final Step!'
    expect(page).to have_content "To complete your membership we need to verify that we're sending emails to the correct address."
  end
  within('.navbar.navbar-default') do
    find('.days-left').click
  end
  expect(page).to have_content 'Upgrade your membership'
  student_picks_a_subscription_plan(usd, 1)
  enter_credit_card_details('valid')
  find('.upgrade-sub').click
  sleep(5)
  within('#thank-you-message') do
    expect(page).to have_content 'Thanks for upgrading your subscription!'
  end
  visit_my_profile
  click_on 'Subscriptions'
  expect(page).to have_content 'Billing Interval:   Monthly'
  end

def sign_up_and_upgrade_from_free_trial_small_device
  visit root_path
  user_password = ApplicationController.generate_random_code(10)
  within('#sign-up-form') do
    student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
  end
  within('#thank-you-message') do
    expect(page).to have_content 'Final Step!'
    expect(page).to have_content "To complete your membership we need to verify that we're sending emails to the correct address."
  end
  within('.navbar.navbar-default') do
    find('.navbar-toggle').click
    click_link 'Upgrade your account'
  end
  sleep(5)
  expect(page).to have_content 'Upgrade your membership'
  student_picks_a_subscription_plan(usd, 1)
  enter_credit_card_details('valid')
  find('.upgrade-sub').click
  sleep(5)
  within('#thank-you-message') do
    expect(page).to have_content 'Thanks for upgrading your subscription!'
  end
  visit account_path
  click_on 'Subscriptions'
  expect(page).to have_content 'Billing Interval:   Monthly'
end