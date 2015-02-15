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

  #### The Happy Path
  describe 'sign-up with valid details:' do
    describe 'Euro / Ireland /' do
      scenario 'Monthly', js: true do
        student_sign_up_as('Dan', 'Murphy', nil, 'valid', eur, ireland, 1, true)
      end

      scenario 'Quarterly', js: true do
        student_sign_up_as('Eileen', 'McGee', nil, 'valid', eur, ireland, 3, true)
      end

      scenario 'Yearly', js: true do
        student_sign_up_as('Tadhg', 'Muircheartaigh', nil, 'valid', eur, ireland, 12, true)
      end
    end

    describe 'GBP / UK /' do
      scenario 'Monthly', js: true do
        student_sign_up_as('Arthur', 'Gasquione', nil, 'valid', gbp, uk, 1, true)
      end

      scenario 'Quarterly', js: true do
        student_sign_up_as('Spencer', 'Hesketh-Smyth', nil, 'valid', gbp, uk, 3, true)
      end

      scenario ' Yearly', js: true do
        student_sign_up_as('St.John', 'Peutty', nil, 'valid', gbp, uk, 12, true)
      end
    end

    describe 'USD / USA /' do
      scenario 'Monthly', js: true do
        student_sign_up_as('Dale', 'Rothschild', nil, 'valid', usd, usa, 1, true)
      end

      scenario 'Quarterly', js: true do
        student_sign_up_as('Joel', 'Goldman', nil, 'valid', usd, usa, 3, true)
      end

      scenario 'Yearly', js: true do
        student_sign_up_as('Sean', 'Mahony', nil, 'valid', usd, usa, 12, true)
      end
    end
  end

  #### The un-happy path

  describe 'sign-up with problems:' do
    describe 'bad user details -' do
      scenario 'bad first name', js: true do
        student_sign_up_as('D', 'Smith', nil, 'valid', eur, ireland, 1, false)
      end

      scenario 'bad last name', js: true do
        student_sign_up_as('Dan', 'S', nil, 'valid', eur, ireland, 1, false)
      end

      scenario 'bad email', js: true do
        student_sign_up_as('Jo', 'Ng', 'a@bcd', 'valid', eur, ireland, 1, false)
      end
    end

    describe 'bad credit card details -' do
      scenario 'card expired', js: true do
        student_sign_up_as('Sean', 'Mahony', nil, 'expired', usd, usa, 12, false)
      end

      scenario 'bad cvc', js: true do
        student_sign_up_as('Sean', 'Mahony', nil, 'bad_cvc', usd, usa, 12, false)
      end

      scenario 'card declined', js: true do
        student_sign_up_as('Sean', 'Mahony', nil, 'declined', usd, usa, 12, false)
      end

      scenario 'card number invalid', js: true do
        student_sign_up_as('Sean', 'Mahony', nil, 'bad_number', usd, usa, 12, false)
      end

      scenario 'card processing error', js: true do
        student_sign_up_as('Sean', 'Mahony', nil, 'processing_error', usd, usa, 12, false)
      end
    end
  end


  #### Helpers

  def student_sign_up_as(user_first_name, user_second_name, user_email, card_type, currency, country, subscription_months, expect_sign_up)
    enter_user_details(user_first_name, user_second_name, user_email, country)
    expect(page).to have_content currency.leading_symbol
    student_picks_a_subscription_pllan(currency, subscription_months)
    enter_credit_card_details(card_type)
    click_button I18n.t('views.student_sign_ups.form.submit')
    sleep 1
    if expect_sign_up
      sleep 1
      expect(page).to have_content I18n.t('controllers.student_sign_ups.create.flash.success')
    else
      expect(page).not_to have_content I18n.t('controllers.student_sign_ups.create.flash.success')
    end
  end

end
