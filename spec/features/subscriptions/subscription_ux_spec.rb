require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'Subscription UX:', type: :feature do


  include_context 'system_setup'
  include_context 'users_and_groups_setup'
  include_context 'course_content'

  # All this calls stripe test platform - needs to be reworked to not call stripe
  before(:each) do
    activate_authlogic

    stripe_monthly_plan = Stripe::Plan.create(amount: (subscription_plan_gbp_m.price.to_f * 100).to_i,
                                              currency: subscription_plan_gbp_m.currency.try(:iso_code).try(:downcase),
                                              interval: 'month',
                                              name: 'LearnSignal Test' + subscription_plan_gbp_m.name.to_s,
                                              interval_count: subscription_plan_gbp_m.payment_frequency_in_months.to_i,
                                              id: Rails.env + '-' + ApplicationController::generate_random_code(20))
    subscription_plan_gbp_m.update_attribute(:stripe_guid, stripe_monthly_plan.id)
    stripe_monthly_plan = Stripe::Plan.create(amount: (subscription_plan_gbp_q.price.to_f * 100).to_i,
                                              currency: subscription_plan_gbp_q.currency.try(:iso_code).try(:downcase),
                                              interval: 'month',
                                              name: 'LearnSignal Test' + subscription_plan_gbp_q.name.to_s,
                                              interval_count: subscription_plan_gbp_q.payment_frequency_in_months.to_i,
                                              id: Rails.env + '-' + ApplicationController::generate_random_code(20))
    subscription_plan_gbp_q.update_attribute(:stripe_guid, stripe_monthly_plan.id)

    visit new_student_path
    user_password = ApplicationController.generate_random_code(10)
    within('#new_user') do
      student_sign_up_as('John', 'Smith', 'john@example.com', user_password)
    end
    expect(page).to have_content 'Fantastic! Check your inbox now'
    visit user_verification_path(email_verification_code: User.last.email_verification_code)
    expect(page).to have_content 'Congratulations! Your LearnSignal account is now active'

    visit new_subscription_path
    student_picks_a_subscription_plan(gbp, 1)
    enter_credit_card_details('valid')
    within('.check.terms_and_conditions') do
      find('span').click
    end
    click_on I18n.t('views.users.upgrade_subscription.upgrade_subscription')
    sleep(10)
    within('#thank-you-message') do
      expect(page).to have_content 'Thanks for choosing a subscription!'
    end

  end

  scenario 'user can change their subscription plan', js: true do
    visit_my_profile
    click_link(I18n.t('views.user_accounts.subscription_info.tab_heading'))
    expect(page).to have_content 'Active Subscription'
    click_link(I18n.t('views.users.show.change_subscription_plan'))
    visit account_change_plan_path
    expect(page).to have_content 'Simply select your new plan'

    find("#sub-GBP-3").click
    within("#sub-GBP-3") do
      find('.plan-option').click
    end
    click_on 'Change Plan'
    expect(page).to have_content(I18n.t('controllers.subscriptions.update.flash.success'))
    sign_out
  end

  scenario 'user can cancel a subscription', js: true do

    visit_my_profile
    click_link(I18n.t('views.user_accounts.subscription_info.tab_heading'))
    find('.confirm-cancellation-modal').click

    click_link(I18n.t('views.users.show.confirm_subscription_cancellation'))
    expect(page).to have_content 'Your Subscription has been cancelled'
    visit_my_profile
    click_on I18n.t('views.user_accounts.subscription_info.tab_heading')
    expect(page).to have_content I18n.t('views.users.show.un_cancel_subscription.h3')
    sign_out
  end

  scenario 'user can update card details', js: true do
    visit_my_profile
    expect(page).to have_content I18n.t('views.user_accounts.payment_details.tab_heading')
    click_on I18n.t('views.user_accounts.payment_details.tab_heading')

    within('#add-card') do
      find('.add-card').click
    end

    within('#new-subscription-payment-card-form') do
      %w(valid_visa_debit ).each do |this_card|
        sleep 2
        enter_credit_card_details(this_card)
        click_button('Add New Card')
      end
    end
    sleep 5
    expect(page).to have_content I18n.t('controllers.subscription_payment_cards.create.flash.success')
    expect(page).not_to have_content I18n.t('controllers.subscription_payment_cards.create.flash.error')

    sign_out
  end

  sleep(10)
end

