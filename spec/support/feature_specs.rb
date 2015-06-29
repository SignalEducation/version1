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

def sign_in_via_navbar(user)
  visit root_path
  within('.nav #login_form') do
    fill_in I18n.t('views.user_sessions.form.email'), with: user.email
    fill_in I18n.t('views.user_sessions.form.password'), with: user.password
    click_button I18n.t('views.general.go')
  end
  expect(page).to have_content I18n.t('controllers.user_sessions.create.flash.success')
end

def sign_in_via_sign_in_page(user)
  visit root_path
  within('.navbar-main') do
    click_link 'Sign In'
  end
  within('.well.well-sm') do
    fill_in I18n.t('views.user_sessions.form.email'), with: user.email
    fill_in I18n.t('views.user_sessions.form.password'), with: user.password
    click_button I18n.t('views.general.sign_in')
  end
  expect(page).to have_content I18n.t('controllers.user_sessions.create.flash.success')
end

def sign_out
  click_link('navbar-cog')
  click_link(I18n.t('views.general.sign_out'))
end

def visit_my_profile
  click_link('navbar-cog')
  click_link(I18n.t('views.users.show.h1'))
  expect(page).to have_content maybe_upcase I18n.t('views.users.show.h1')
end

def edit_my_profile
  visit_my_profile
  click_link I18n.t('views.general.edit')
  expect(page).to have_content maybe_upcase I18n.t('views.users.edit.h1')
end

#### Student sign_up process

def student_sign_up_as(user_first_name, user_second_name, user_email, card_type, currency, country, subscription_months, expect_sign_up)
  enter_user_details(user_first_name, user_second_name, user_email, country)
  expect(page).to have_content currency.leading_symbol
  student_picks_a_subscription_plan(currency, subscription_months)
  enter_credit_card_details(card_type)
  click_button I18n.t('views.student_sign_ups.form.submit')
  sleep 1
  if expect_sign_up
    sleep 2
    expect(page).to have_content I18n.t('controllers.student_sign_ups.create.flash.success')
  else
    expect(page).not_to have_content I18n.t('controllers.student_sign_ups.create.flash.success')
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

def enter_user_details(first_name, last_name, email=nil, country)
  fill_in('user_first_name', with: first_name)
  fill_in('user_last_name', with: last_name)
  fill_in('user_email', with: email || "#{first_name.downcase}_#{rand(999999)}@example.com")
  page.execute_script("$('#user_country_id').val(#{country.id}); clearPlans(); showPlans(); return false;")
  temp_password = ApplicationController.generate_random_code(10)
  fill_in('user_password', with: temp_password)
  fill_in('user_password_confirmation', with: temp_password)
end

def student_picks_a_subscription_plan(currency, payment_frequency)
  expect([1,3,12].include?(payment_frequency)).to eq(true)
  find("#sub-#{currency.iso_code}-#{payment_frequency}").click
end
