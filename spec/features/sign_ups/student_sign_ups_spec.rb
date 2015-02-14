require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'

describe 'The student sign-up process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'

  before(:each) do
    activate_authlogic
    visit root_path
    click_link I18n.t('views.general.sign_up')
    expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
  end

  scenario 'sign-up with valid details - Ireland and Euro', js: true do
    complete_user_details('Dan','Smith', nil, ireland)
    expect(page).to have_content '€'
    complete_credit_card('valid')
    sleep 10
  end

  #### Helpers

  def complete_credit_card(card_type='valid')
    case card_type
      when 'valid'
        complete_card_details('4242424242424242','123','12',Time.now.year + 1)
      when 'expired'
        complete_card_details('4242424242424242','123','12',Time.now.year - 1)
      when 'declined'
        complete_card_details('4242424242424242','123','12',Time.now.year - 1)
      when 'bad_number'
        complete_card_details('4242424242424242','123','12',Time.now.year - 1)
      else
        complete_card_details('4242424242424242','123','12',Time.now.year)
    end
  end

  def complete_card_details(card, cvv, exp_month, exp_year)
    fill_in('card_number', with: card)
    fill_in('cvv_number', with: cvv)
    select exp_month, from: 'expiry_month'
    select exp_year, from: 'expiry_year'
  end

  def complete_user_details(first_name, last_name, email=nil, country)
    fill_in('user_first_name', with: first_name)
    fill_in('user_last_name', with: last_name)
    fill_in('user_email', with: email || "#{first_name.downcase}-#{rand(999999)}@example.com")
    select country.name, from: 'user_country_id'
    temp_password = ApplicationController.generate_random_code(10)
    fill_in('user_password', with: temp_password)
    fill_in('user_password_confirmation', with: temp_password)
  end

end
