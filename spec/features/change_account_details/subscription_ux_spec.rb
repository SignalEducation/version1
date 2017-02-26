require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'

describe 'Subscription UX:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup' # starts StripeMock up for us.

  let!(:subscription_1) { x = FactoryGirl.create(:subscription,
                          user_id: individual_student_user.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token)
                          individual_student_user.update_attribute(:stripe_customer_id, x.stripe_customer_id)
                          x }
  let!(:subscription_2) { x = FactoryGirl.create(:subscription,
                          user_id: corporate_customer_user.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token)
                          corporate_customer_user.update_attribute(:stripe_customer_id, x.stripe_customer_id)
                          x }
  #before { StripeMock.start }
  after { StripeMock.stop }

  before(:each) do
    a = admin_user
    b = individual_student_user
    activate_authlogic
  end

  xit scenario 'user can upgrade a subscription', js: true do
    sign_up_and_upgrade_from_free_trial
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link(I18n.t('views.users.show.tabs.subscriptions'))
    click_link(I18n.t('views.users.show.change_subscription_plan'))
    expect(page).to have_content 'Select a new plan'
    #click_on(".plans").("#subscription-panel-8")
    page.evaluate_script('$("#plans .subscription-panel").last().attr("id")').click
    click_button(I18n.t('views.general.save'))
    # page should reload
    expect(page).to have_content(I18n.t('controllers.subscriptions.update.flash.success'))
    expect(page).to have_content 'Billing Interval:   Quarterly'
    sign_out
  end

  scenario 'user can cancel and reactivate a subscription', js: true do
    sign_up_and_upgrade_from_free_trial
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link(I18n.t('views.users.show.tabs.subscriptions'))
    cancel_and_un_cancel_account
    sign_out
  end

  xit scenario 'student_user can un-cancel a canceled-pending subscription', js: :true do
    # sign up as a student
    sign_up_and_upgrade_from_free_trial
    # go to my-profile page
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link('Subscriptions')

    # cancel the account and reactivate it
    cancel_and_un_cancel_account

    # happy ending
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    expect(page).to have_content 'active'

    sign_out
  end

  xit scenario 'student_user can view invoices', js: true do
    # sign up as a student
    visit root_path
    click_link 'Sign Up'
    expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
    student_sign_up_as('Dan', 'Murphy', nil, 'valid', eur, ireland, 1, true)

    # go to my-profile page
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link('Subscriptions')

    expect(page).to have_content maybe_upcase I18n.t('views.users.show.your_invoices')

    within('#invoices-panel') do
      expect(page).not_to have_content(I18n.t('views.invoices.index.print'))
      click_link('Refresh')
      expect(page).to have_css('#invoices-table')
      expect(page).to have_content(I18n.t('views.invoices.index.print'))
      click_link(I18n.t('views.invoices.index.print'))
    end

    # on the print page
    expect(page).to have_css('.glyphicon-print')
    click_link(I18n.t('views.users.show.h1'))
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')

    sign_out
  end

  scenario 'user can update card details', js: true do
    # sign up as a student
    sign_up_and_upgrade_from_free_trial
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')

    click_on I18n.t('views.users.show.tabs.payments')

    click_link(I18n.t('views.users.show.new_card'))
    # omitted:
    # - bad_number: can't get off the Modal
    # - valid: already on file
    #%w(expired bad_cvc declined processing_error valid_visa_debit
    #valid_mc_debit).each do |this_card|
    %w(valid_visa_debit ).each do |this_card|
      sleep 2
      #click_link(I18n.t('views.users.show.tabs.payments'))
      # new card modal
      #sleep 2
      enter_credit_card_details(this_card)
      click_button(I18n.t('views.general.save'))
      sleep 2

      # back at the subscriptions page
      if this_card.include?('valid')
        sleep(1)
        expect(page).to have_content I18n.t('controllers.subscription_payment_cards.create.flash.success')
        expect(page).not_to have_content I18n.t('controllers.subscription_payment_cards.create.flash.error')
      else
        expect(page).not_to have_content I18n.t('controllers.subscription_payment_cards.create.flash.success')
        expect(page).to have_content I18n.t('controllers.subscription_payment_cards.create.flash.error')
      end
    end

    # There are now three cards on file. Select an alternate to be the default
    #%w(4242 5556 8210).each do |last4|
    #  within('#credit-cards-panel') do
    #    within("#card-#{last4}") do # Visa Debit
    #      expect(page).not_to have_css('.label-success')
    #      click_link(I18n.t('views.users.show.use_this_card'))
    #      expect(page).to have_css('.label-success')
    #    end
    #  end
    #end

    sign_out
  end

  def cancel_and_un_cancel_account
    click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
    page.driver.browser.switch_to.alert.dismiss

    click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
    page.driver.browser.switch_to.alert.accept

    expect(page).to have_content 'Your Subscription has been cancelled'
    click_on 'Subscription Info'
    expect(page).to have_content I18n.t('views.users.show.un_cancel_subscription.h3')
    click_link(I18n.t('views.users.show.un_cancel_subscription.button_call_to_action'))

    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_on 'Subscription Info'
    expect(page).to have_content 'Account Status: Valid Subscription'
    expect(page).to have_content(I18n.t('controllers.subscriptions.update.flash.success'))
  end

  def check_that_the_plans_are_visible(plans)
    expect(plans.size).to be > 1
    expect(plans.size).to be <= 3
    plans.each do |option|
      expect(page).to have_content maybe_upcase option.name
      option.description.lines.each do |line|
        expect(page).to have_content line
      end
    end
  end
  sleep(10)
end

